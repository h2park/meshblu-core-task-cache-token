crypto = require 'crypto'
TokenManager = require 'meshblu-core-manager-token'

class CacheToken
  constructor: (options={}) ->
    {@cache,pepper,uuidAliasResolver} = options
    @tokenManager = new TokenManager {pepper, uuidAliasResolver}

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    @tokenManager.hashToken uuid, token, (error, hashedToken) =>
      return callback error if error?

      @cache.set "#{uuid}:#{hashedToken}", '', (error) =>
        return callback error if error?
        callback null,
          metadata:
            responseId: request.metadata.responseId
            code: 204
            status: 'No Content'

module.exports = CacheToken
