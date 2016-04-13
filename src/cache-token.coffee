http   = require 'http'
crypto = require 'crypto'
TokenManager = require 'meshblu-core-manager-token'

class CacheToken
  constructor: (options={}) ->
    {@cache,pepper,uuidAliasResolver} = options
    @tokenManager = new TokenManager {pepper, uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    return @_doCallback request, 404, callback unless uuid? and token?

    @tokenManager.hashToken uuid, token, (error, hashedToken) =>
      return callback error if error?
      return @_doCallback request, 404, callback unless hashedToken?

      @cache.setex "#{uuid}:#{hashedToken}", 86400, '', (error) =>
        return callback error if error?
        return @_doCallback request, 204, callback

module.exports = CacheToken
