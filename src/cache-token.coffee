crypto = require 'crypto'

class CacheToken
  constructor: (options={}) ->
    {@cache,@pepper} = options

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    hashedToken = @_hashToken uuid, token

    @cache.set "#{uuid}:#{hashedToken}", '', (error) =>
      return callback error if error?
      callback null,
        metadata:
          responseId: request.metadata.responseId
          code: 204
          status: 'No Content'

  _hashToken: (uuid, token) =>
    hasher = crypto.createHash 'sha256'
    hasher.update uuid
    hasher.update token
    hasher.update @pepper
    hasher.digest 'base64'

module.exports = CacheToken
