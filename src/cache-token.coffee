crypto = require 'crypto'
TokenManager = require 'meshblu-core-manager-token'

class CacheToken
  constructor: (options={}) ->
    {@cache,@pepper} = options
    @tokenManager = new TokenManager pepper: @pepper

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    hashedToken = @tokenManager.hashToken uuid, token

    @cache.set "#{uuid}:#{hashedToken}", '', (error) =>
      return callback error if error?
      callback null,
        metadata:
          responseId: request.metadata.responseId
          code: 204
          status: 'No Content'

module.exports = CacheToken
