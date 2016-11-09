# Supersonic Changelog

Issues are tracked in AppGyver's [unified issue tracker](https://github.com/appgyver/steroids/issues) – please post bug reports and feature requests there.

## 1.14.0 (2016-11-09)

`supersonic.data.Model` find queries are now completely cached, just like findAll queries.

Changes:

- Updates ag-data to 1.2.0

## 1.13.2 (2016-09-09)

Fixes issue where splashscreen would no longer autohide on iOS 10. To fix the issue for existing apps, upgrade Supersonic to v1.13.2 or newer (with `bower update`). Then, in the app's layout file, modify the `<script>` tag that loads `webcomponents.js` to load `webcomponents-lite.js` instead.

Changes:

- Utilize webcomponents.js version 0.7.22 and `webcomponents-lite.js` to circumvent iOS 10 issues with native shadow DOM.

## 1.10.0 (2016-02-24)

Features:

- `supersonic.data.Model` now supports Composer 2 record-level ACL.

## 1.9.9 (2016-02-03)

Features:

- `supersonic.auth.groups` provides accessors to the groups of the current Composer 2 application

## 1.9.8 (2016-01-20)

Fixes:

- Sporadic console errors with `querySelectorAll` being used without a valid `document.body`

## 1.9.7 (2016-01-13)

Fixes:

- A typo in the `superify` debug logging mechanism breaking when encountering a stream error ([see pull request #115](https://github.com/AppGyver/supersonic/pull/115))

## 1.9.6 (2016-01-13)

Fixes:

- Race condition with `supersonic.data.model` change listeners possibly not seeing the `error.unrecoverable` flag (see release 1.9.4)

## 1.9.5 (2015-12-22)

Fixes:

- Configures `supersonic.auth.users` with the same default caching options as `supersonic.data.model` ([see pull request](https://github.com/AppGyver/supersonic/pull/112))

## 1.9.4 (2015-12-16)

Changes:

- Allow `supersonic.data.model` change listeners to detect whether an error is unrecoverable and no more events will be sent using `error.unrecoverable`.

## 1.9.3 (2015-12-14)

Fixes:

- Enables `supersonic.module.attributes` to be read for module frames where the module was included via the `srcdoc` attribute

## 1.9.2 (2015-12-10)

Fixes:

- Prevents a scenario where `supersonic.module` drivers did not receive a valid `route` uid in the `context` argument ([see pull request](https://github.com/AppGyver/supersonic/pull/102))

## 1.9.1 (2015-12-10)

Fixes:

- Prevents module attributes from outside a modal module iframe leaking into the modal in web.

## 1.9.0 (2015-12-02)

Features:

- `whenChanged` methods in `supersonic.data.model` support an error callback argument

Changes:

- `whenChanged` will stop polling for updates if an unrecoverable error (HTTP 4xx) is encountered

## 1.8.9 (2015-11-10)

Fixes:
- Module soft tabs fixed to work in chrome/android.

## 1.8.8 (2015-11-06)

Fixes:
- Workaround for Android's "Connection Refused" problem with iframes.
  Issue: [XWALK-5621](https://crosswalk-project.org/jira/browse/XWALK-5621)

## 1.8.7 (2015-11-05)

Fixes:
- Hide module chromes when in tabs.
- Use wide chromes in mobile.

## 1.8.6 (2015-10-30)

Tabs for composer 2

Features:
- Adds soft tabs support for Composer 2

## 1.8.5 (2015-10-28)

Improves the time to getting refreshed data from `whenChanged`.

Changes:
- `supersonic.data.model` instances use a different polling logic for `whenChanged` by default. Pollers are started when the view is visible and stopped while the view is hidden.
- The default polling interval for `supersonic.data.model` instances is 1000ms (down from 10000ms) when caching is enabled.

## 1.8.4 (2015-10-27)

Changes:
- Composer2 modules will check for http://localhost workaround only on Android.

Fixes:
- Prevents an issue with the `localStorage` cache adapter from preventing `supersonic.data` cache expirations.


## 1.8.3 (2015-10-26)

Changes:
- Support for deferred loading of iframes via the `ag-src` property. Circumvents an issue with requests to `localhost` on Android.

## 1.8.2 (2015-10-21)

Changes:
- Support for blocking UI interactions while there are `supersonic.data` requests ongoing. Requires iOS client version 4.0.7 or Android client version 4.1.0.

## 1.8.1 (2015-10-14)

Changes:
- Files uploaded via `supersonic.data` get additional metadata stored, containing their mimetype, and get a filename determined based on the file uploaded instead of using an automatically generated one.

## 1.8.0 (2015-10-09)

Features:
- Adds the `supersonic.module.notifications` namespace for sending out notification events from Composer modules

## 1.7.10 (2015-10-02)

Fix:
- Bring back some module APIs which were made private in 1.7.8.

## 1.7.9 (2015-10-02)

Features:
- Enhanced uploading can be requested with `X-AG-Image-Uploader` headers:
  - Display a native progress bar on upload.
  - Transparently resize uploaded PNG and JPEG images.
  - See example usage in `testApp`.

Changes:
- Set Module runtime's initial visibility on DOM Content Loaded event.

## 1.7.8 (2015-09-30)

Changes:
- Hide the module container instead of the module iframe itself.
  Module might have external chrome which needs to be hidden also to
  prevent blinking.

## 1.7.7 (2015-09-29)

Features:
- Remove from the DOM Composer modules which are not currently visible.
  For example:
  - on `layers.push()` hide modules on the previous layer and bring
  them back on `layers.pop()`.
  - hide modules on Tab A when navigating to Tab B.
- `supersonic.ui.dialog.spinner.*` displays a spinner which can block either
  the current webview or the whole app.
- PreviewFileView now supports remote URLs
- New API to display a media gallery:
~~~
  mediaGallery = new supersonic.ui.MediaGallery([
    "http://www.mydomain.com/images/promo01.jpg"
    "images/floor_plan.jpg"
    "videos/movie.mp4"])

  mediaGallery.start()
~~~

## 1.7.6 (2015-09-15)

Fixes:
- `supersonic.data.model` cache inconsistencies ([closes issue #1022](https://github.com/AppGyver/steroids/issues/1022))

## 1.7.5 (2015-09-10)

Features:
- Update webcomponents.js to v0.7.12

## 1.7.4 (2015-09-09)

Fixes:
- Enhanced cross-browser compatibility for Composer Module iframes. Prevents iframes that would not ever resize on Chrome.
- More robust handling of Composer Module iframe lifetime events. Prevents stale listeners after iframe removal.

## 1.7.3 (2015-09-08)

Fixes:
- Loading spinner fors Composer Module iframes are removed after frame document body is available. Prevents stale spinners.
- Supersonic uses the topmost frame that has supersonic for `postMessage` communication. Prevents `supersonic.data.channel` from being unavailable to modules in nested iframes.

## 1.7.2 (2015-09-03)

Fixes:
- Composer Module iframe heights track content height better when images are involved.

## 1.7.1 (2015-09-02)

Features:
- Offer minified versions of JS distributables (`supersonic.core.min.js` and `supersonic.min.js`)

Fixes:
- Update schema for `supersonic.auth.users` to allow changing the user's password.

## 1.7.0 (2015-09-01)

Features:
- Composer Module iframes waiting for loading to complete show a loading indicator.
- `supersonic.module` navigation functions that accept routes now accept references to the current module's views as `#view-name`.

Changes:
- When supersonic runs in a Composer Module iframe, cordova and steroids from the parent frame will be used.

## 1.6.11 (2015-08-24)

Fixes:
- Add delay to catch fully rendered static modules for correct resizing.

## 1.6.10 (2015-08-21)

Fixes:
- Overwrite Ionic's default `overflow:hidden` which blocks scrolling for Crosswalk 14.

## 1.6.9 (2015-08-21)

Fixes:
- Composer Module iframe sizes automatically scale according to their content height

## 1.6.8 (2015-08-21)

Fixes:
- `supersonic.data.channel` uses `postMessage` from `window.top` to ensure message propagation from Composer Modules
- `supersonic.module.attributes` looks for attributes from both `window` and `window.parent`
- Behavior of navigation APIs in `supersonic.module` improved to enable compatibility with the Composer Module web development harness in Steroids Connect

## 1.6.7 (2015-08-17)

Fix:
- Data channels window.postMessage uses second argument

## 1.6.6 (2015-08-13)

Fix:
- Fix wrongly named variable


## 1.6.5 (2015-08-13)

Fix:
- Fix resolving module path twice in modal route

## 1.6.4 (2015-08-13)

Fix:
- Fix a bug on module router that happens during the validation of required parameters.
- Fix module modal so that it accepts parameters
- Fix module iframe height observers to detect dynamically added iframes
- Fix module iframe height fixing in Chrome

## 1.6.3 (2015-08-07)

Features:
- `supersonic.module.modal` allows showing and hiding modals based on routes.

## 1.6.2 (2015-08-05)

Changes:
- `supersonic.module.layers` accesses environment-specific functionality through `supersonic.module.drivers`

Features:
- Current driver for a view and all its iframes can be accessed through `supersonic.module.drivers.current`

## 1.6.1 (2015-08-03)

Changes:
- `supersonic.module.router` root path for Modules under `/dist` is now `/modules`

## 1.6.0 (2015-07-30)

Introduces navigation between Composer Modules.

- `supersonic.module.router` maps Composer Module route to installed Modules
- `supersonic.module.layers` allows pushing and popping Module views from the view stack based on routes

## 1.5.11 (2015-07-03)

Fixes:
- Switch the default `supersonic.data` cache adapter for a functioning one. The defective adapter caused caching to be effectively disabled.

## 1.5.10 (2015-07-02)

Features:
- `supersonic.module.transitions` provides view transition animations for Composer Modules

## 1.5.9 (2015-06-17)

Changes:
- Saving a Supersonic Data model instance merges the server response to the instance instead of replacing the whole instance state.

Fixes:
- Prevented the potential for a state leak in the HTTP layer of Supersonic Data. `X-Job-Id` headers would get reused by accident in some scenarios.

## 1.5.8 (2015-06-16)

Pre-features:
- Enabling/Disabling the Drawer via API. Closes [#749](https://github.com/AppGyver/steroids/issues/749). *Note: This feature requires wrapper support, which will be out shortly. Until then, the API calls will not work.*

Fixes:
- Brought back spinning icons that were removed in Supersonic 1.5.7. Closes [#945](https://github.com/AppGyver/steroids/issues/945).

## 1.5.7 (2015-06-08)
Changes:
- Updated Supersonic CSS to match Ionic's v1.0.0 "uranium-unicorn" release.

Breaking Changes:
- Updated Ionicons to v2.0.1. Naming convention for iOS icons changed from `<icon prefix>-ios7-<icon name>` to `<icon prefix>-ios-<icon name>`.

*Note: These updates include minor cosmetic tweaks to the UI – nothing major. That said, you might still want to check your app to ensure everything looks as it should after the update. For those interested, full list of changes can be found in [this commit](https://github.com/AppGyver/supersonic/commit/3b4fd6059bddf23ea0fff06617b6525f8090977d).*
## 1.5.6 (2015-06-04)

Features:
- `supersonic.module.attributes` allows access to AppGyver Enterprise Module instance context

## 1.5.5 (2015-05-22)

Changes:
- `supersonic.data.model` uses `localStorage` instead of `localforage` for the default cache storage adapter

## 1.5.4 (retracted)

## 1.5.3 (2015-05-22)

Features:
- Iframes with `data-module` attribute are detected as AppGyver Enterprise Modules. Their height is automatically adjusted to fit the content height.

Bugfixes:
- The promises returned by `supersonic.ui.View.start()` and `supersonic.ui.views.start()` now resolve to the `startedView` object as intended.

## 1.5.2 (2015-05-08)

Features:
- Support Enterprise users in the `super-data-repeat` component.

Changes:
- `supersonic.auth.users.getCurrentUser` provides a meaningful error message
  if session is not available

## 1.5.1 (2015-05-07)

Fix:
- `supersonic.data.model` reads configuration from `supersonic.env` if it's available

## 1.5.0 (2015-05-07)

Features:
- `supersonic.auth.session` provides accessors to the currently authenticated
  AppGyver Enterprise Session
- `supersonic.auth.users` provides accessors to the users of the
  current AppGyver Enterprise application
- `supersonic.env` provides information of the current AppGyver Enterprise
  application environment

## 1.4.0 (2015-04-23)

Changes:
- Enable caching by default for `supersonic.data.model`.
- Set authorization header by default for `supersonic.data.model`.

## 1.3.0 (2015-04-15)

Features:
- `supersonic.data.model` supports direct file uploads for model fields configured with the type `file`.

## 1.2.2 (2015-04-02)

Features:
- Asynchronous job protocol for slow HTTP endpoints also includes a feature flag in the `X-Feature-Jobs` header to improve backwards compatibility.

## 1.2.1 (2015-03-31)

Features:
- `supersonic.data.storage.adapters` exposes factories for the default `localforage` adapter and an in-memory storage, which can be used as `supersonic.data.model` cache adapters.

## 1.2.0 (2015-03-26)

Features:
- Asynchronous job protocol enabled when accessing slow HTTP endpoints over the AG proxy v3 API.

## 1.1.2 (2015-02-25)

Bugfixes:
- `super-navbar`, `super-navbar-title` and `super-navbar-button` properly hide their content from the DOM

## 1.1.1 (2015-01-21)

Features:
- Custom animation support to `supersonic.ui.layers.push` (iOS-only, see [open ticket](https://github.com/AppGyver/steroids/issues/776) about Android native support). Closes [#721](https://github.com/AppGyver/steroids/issues/721).

## 1.1.0 (2015-01-20)

Features:
- Updated Supersonic CSS to match Ionic's v1.0.0-beta.14 "magnesium-mongoose" release.
- Re-enabled some disabled Ionic components to ensure better backwards compatibility with Ionic apps.

*Note: These updates include minor cosmetic tweaks to the UI – nothing major. That said, you might still want to check your app to ensure everything looks as it should after the update. For those interested, full list of changes can be found in [this commit](https://github.com/AppGyver/supersonic/commit/9bc7e85b355206087ff9722954e982957ca21304).*

## 1.0.11 (2015-01-08)

Features:
- Added 3-way data binding support for single records by `one(123).whenChanged` on `supersonic.data.model`

Bugfixes:
- Resolved issue with `defaultStorage` for `supersonic.data.model` not being defined and the `cache` flag not working without specifying a storage

## 1.0.10 (2014-12-22)

Bugfixes:
- Fixed a bug causing the `timeToLive` option for `supersonic.data.model`'s `cache` to not be adhered

## 1.0.9 (2014-12-19)

Features:
- Added `cache` option support for `supersonic.data.model`

## 1.0.8 (2014-12-18)

Features:
- Added `supersonic.ui.layers.replace` API call for replacing the whole navigation stack with a started view.

Bugfixes:
- Fixed a bug where views returned by `supersonic.ui.views.find` didn't always have the correct `id` set.

## 1.0.7 (2014-12-12)

Bugfixes:
- Fix an inconsistency in handling `supersonic.data.model` instance state when serializing (`.toJson`) and unserializing (`.fromJson`)

## 1.0.6 (2014-12-12)

Features:
- `.fromJson` on `supersonic.data.model` assumes all the data is in a dirty state, so it will be sent to the cloud in case of `.save()`

## 1.0.5 (2014-12-12)

Features:
- Added `.fromJson` support to to complement `instance.toJson` on `supersonic.data.model`

## 1.0.4 (2014-12-11)

Bugfixes:
- `supersonic.ui.views.start()` and `supersonic.ui.views.stop()` now properly return the View object started/stopped.

## 1.0.3 (2014-12-10)

Features:
- Added option support for `supersonic.data.model`
- Added `supersonic.data.storage.property`

## 1.0.2 (2014-12-10)

- Added support for data-params for super-navbar-button when using "location" or "view-id" parameters (as in super-navigate).

## 1.0.1 (2014-12-05)

- Fixed using super-navigate component, layers.push, modal.show data parameters passing in android.

## 1.0.0 (2014-12-03) – MACH 1

Initial release. See the documentation at [http://docs.appgyver.com](http://docs.appgyver.com) for more information.

Bunch of outstanding issues in Steroids.js and other components fixed or made obsolete by Supersonic features:

- The `network.extraResponseHeaders` property in `config/app.coffee` can be used to set custom headers that will be appended to all incoming HTTP responses, allowing e.g. CORS issues to be circumvented for good. iOS-only for the moment, fixes [#124](https://github.com/AppGyver/steroids/issues/124), [#140](https://github.com/AppGyver/steroids/issues/140) and [#150](https://github.com/AppGyver/steroids/issues/150) for iOS.
- New app configs at `config/app.coffee` and `config/structure.coffee` deprecate `config/application.coffee` and the various `config.xml` files. Closes [#194](https://github.com/AppGyver/steroids/issues/194) and [#175](https://github.com/AppGyver/steroids/issues/175).
- New http://docs.appgyver.com sources are public on [GitHub](https://github.com/AppGyver/supersonic/tree/master/docs). Closes [#237](https://github.com/AppGyver/steroids/issues/237).
- Supersonic Routes remove the need for explicit view URLs. Closes [#285](https://github.com/AppGyver/steroids/issues/285).
- Deprecated keyboard `config.ios.xml` settings, since the new keyboard plugin introduced in [iOS runtime v4.0.0](https://github.com/AppGyver/scanner/blob/master/changelog-ios.md#400-2014-10-10-native-css-with-pixate) no longer supports them. Closes [#101](https://github.com/AppGyver/steroids/issues/101) and [#208](https://github.com/AppGyver/steroids/issues/208)
