Promise = require 'bluebird'

module.exports = (env, session, loadResourceBundle) ->
  groupsResourceBundle =
    options:
      baseUrl: env?.auth?.endpoint || ""
    resources:
      groups:
        schema:
          identifier: "id"
          fields:
            id:
              type: "string"
              identity: true
            name:
              type: "string"
            description:
              type: "string"
            users:
              type: "array"
            collection_permissions:
              type: "array"

  GroupModel = loadResourceBundle(groupsResourceBundle).createModel("groups")

  GroupModel
