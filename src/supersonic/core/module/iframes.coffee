Promise = require 'bluebird'
Bacon = require 'baconjs'
debug = require('debug')('supersonic:module:iframes')

module.exports = (window, superglobal) ->

  IFRAME_SELECTOR = "iframe[data-module]"
  MODULE_CONTAINER_SELECTION = ".ag__module-container"
  IFRAME_USE_LOAD_INDICATOR_ATTR = "data-module-indicate-loading"
  IFRAME_NAME_ATTR = "data-module-name"
  LOAD_INDICATOR_TEMPLATE = """
    <div class="super-module__load-indicator">
      <i class="icon super-loading-c"></i>
      &nbsp;
      Loading
      <b bind-module-name></b>...
    </div>
  """

  ###
  Private API functionalities
  ###

  isRuntimeWindow = ->
    window == superglobal

  observeIframeChanges = ->
    Promise.delay(0).then ->
      if window.document.body.querySelectorAll("[data-module-load-indicator-template]").length
        setLoadIndicatorTemplate(window.document.body.querySelectorAll("[data-module-load-indicator-template]")[0].innerHTML)

      streamOfModules = observeDocumentForNewModuleIframes()
      streamOfModules.onValue resizeOnModuleContentChange

      findAll().map resizeOnModuleContentChange

  toggleModuleVisibility = ->
    display = {
      visible: 'block',
      hidden: 'none'
    }

    if (window.document.hidden)
      visibility = display.hidden
    else
      visibility = display.visible

    for moduleContainer in findAllContainers()
      moduleContainer.style.display = visibility

  # Bind event listeners only on the Runtime window (parent of modules).
  # That is, do not bind event listeners in the inside of the module's iframe.
  initRuntimeEventListeners = ->
    return unless isRuntimeWindow()

    window.document.addEventListener "DOMContentLoaded", observeIframeChanges

    # The first tab does not receive `visibilitychange` event so set visibility manually.
    # Execute on all tabs on init, because there's not a reliable mechanism to
    # know what is the first tab.
    window.document.addEventListener "DOMContentLoaded", toggleModuleVisibility, false

    # Remove from the DOM all modules, which aren't on currently visible screen.
    window.document.addEventListener 'visibilitychange', toggleModuleVisibility, false

  # Sometimes iframe loading fails on Android with Connection Refused.
  # Crosswalk ticket: https://crosswalk-project.org/jira/browse/XWALK-5621
  #
  # This will try to fix ALL iframes.
  # Eg. collection header doesn't match iframe[data-module] but it might
  # fail loading.
  #
  # Workaround: try to access any property of `contentWindow`. If iframe loading
  # has failed, a SecurityError will be thrown because the origin of the failed
  # iframe is "null".
  initIframeGuard = ->
    return if !isRuntimeWindow() or !isAndroid()

    # Promise.delay is required because javascript is loaded before the
    # iframe tag appears in the html document. This causes a race-condition
    # on Android. Delaying to next-tick helps.
    Promise.delay(0).then ->
      for iframe in findAll("iframe") then do (iframe) ->
        iframe.onload = ->
          try
            testProperty = iframe.contentWindow.thisDoesntExist

          catch e
            if (e instanceof DOMException && e.name == "SecurityError")
              acualSrc = iframe.src
              iframe.src = ""

              Promise.delay(0).then ->
                console.log "Loading of iframe failed, reloading it", acualSrc
                iframe.src = acualSrc
                hideLoadIndicator iframe
                resizeOnModuleContentChange iframe

  isAndroid = ->
    window.FreshAndroidAPIBridge != null

  observeDocumentForNewModuleIframes = ->
    return Bacon.never() unless window?.MutationObserver?

    Bacon.fromBinder (sink) ->
      observer = new window?.MutationObserver (records) ->
        for record in records
          do (record) ->
            if typeof record.addedNodes is "object"
              for node in record.addedNodes when node.nodeName is "IFRAME"
                if node.hasAttribute("data-module")
                  sink node

      observer.observe(window.document, {childList: true, subtree: true})

  setLoadIndicatorTemplate = (templateString) ->
    LOAD_INDICATOR_TEMPLATE = templateString

  resizeOnModuleContentChange = (element) ->
    return unless isValidFrame element
    debug "Starting to watch element for changes:", element

    if element.hasAttribute(IFRAME_USE_LOAD_INDICATOR_ATTR)
      showLoadIndicator(element)

    Bacon.fromPromise(waitForLoad element)
      .delay(100) # Why do we need to wait?
      .map(-> element)
      .doAction(-> debug "Element loaded:", element)
      .takeWhile(isValidFrame)
      .doAction(hideLoadIndicator)
      .flatMap(iframeContentSizeChangeEvents)
      .doAction(-> debug "Got change event: ", element)
      .takeWhile(isValidFrame)
      .onValue(resize)

  # This will return false for an element removed from the DOM or otherwise inaccessible
  isValidFrame = (iframeElement) ->
    try
      iframeElement?.contentWindow?.document?
    catch e
      false

  waitForLoad = (element) ->
    ###
    We can't rely on any events from the iframe, because it's possible that we
    missed them or that they won't be sent. Therefore we check whether the
    iframe body is defined, which is something that should happen after
    DOMContentLoaded.

    FIXME: `document.body` is also available on iframes which failed loading
           due to Android Connection Refused bug.

    The iframe element might also become invalid at any point, which we need to
    detect.
    ###
    new Promise (resolve, reject) ->
      interval = setInterval ->
        if !isValidFrame element
          clearInterval(interval)
          return reject new Error "Element is not an iframe, or it was removed"

        try
          document = element.contentWindow.document
          if document.body? and document.body.innerHTML
            clearInterval(interval)
            resolve()
        catch e
          clearInterval(interval)
          reject new Error "Unable to access iframe: #{e.message}"
      , 1

  iframeContentSizeChangeEvents = do ->
    contentDocumentBodyMutations = (element) ->
      Bacon.fromBinder((sink) ->
        # Note: the MutationObserver is from the _element's_ window
        observer = new element.contentWindow.MutationObserver ->
          sink element
        observer.observe(element.contentDocument.body, {childList: true, subtree: true})
      )

    addImageLoadEvents = (element) ->
      Bacon.once(element).merge iframeImageOnloadEvents element

    iframeImageOnloadEvents = (element) ->
      Bacon.fromArray(
        image for image in element.contentDocument.body.querySelectorAll("img") when !image.complete
      ).flatMap((image) ->
        Bacon.fromPromise new Promise (resolve) ->
          image.onload = resolve
      ).map(-> element)

    (element) ->
      return Bacon.never() unless isValidFrame element

      contentDocumentBodyMutations(element)
        .flatMap(addImageLoadEvents)
        .merge Bacon.later(500, element) # Do we really need this just-in-cause event?

  findAllContainers = ->
    findAll MODULE_CONTAINER_SELECTION

  ###
  Public API functionalities
  ###

  findAll = (selector = IFRAME_SELECTOR) ->
    Array.prototype.slice.call (window.document?.body?.querySelectorAll?(selector) || [])

  register = (element) ->
    return unless isValidFrame element

    resizeOnModuleContentChange(element)

  resize = do ->
    calculateFrameElementHeight = (element) ->
      style = window.getComputedStyle(element.contentDocument.body, null)
      height = parseInt(style.getPropertyValue("padding-top")) + parseInt(style.getPropertyValue("padding-bottom"))
      for child in element.contentDocument.querySelectorAll("body > *:not(script):not(link):not(style)")
        height += child.offsetHeight
      height

    setFrameElementHeight = (element, height) ->
      element.style.height = "#{height}px"

    (element) ->
      debug "About to resize: ", element
      return element unless isValidFrame element

      height = calculateFrameElementHeight element
      setFrameElementHeight element, height

      debug "Resized element to #{height}px: ", element

      element

  showLoadIndicator = do ->
    generateLoadIndicatorElement = (element) ->
      loadIndicatorElement = window.document.createElement("DIV")
      loadIndicatorElement.setAttribute("data-module-load-indicator", "")
      loadIndicatorElement.innerHTML = LOAD_INDICATOR_TEMPLATE
      for bindableElement in loadIndicatorElement.querySelectorAll("[bind-module-name]")
        bindableElement.innerHTML = element.getAttribute(IFRAME_NAME_ATTR)
      loadIndicatorElement

    (element) ->
      return unless isValidFrame element

      element.style.display = "none"
      element.parentNode.insertBefore(generateLoadIndicatorElement(element), element.nextSibling)

  hideLoadIndicator = (element) ->
    return element unless isValidFrame element

    if element.nextElementSibling?.hasAttribute("data-module-load-indicator")
      element.nextElementSibling.remove()
    element.style.display = "block"
    resize(element)


  ###
  Execute initial operations
  ###

  initRuntimeEventListeners()
  initIframeGuard()

  return {
    findAll
    register
    resize
    showLoadIndicator
    hideLoadIndicator
  }
