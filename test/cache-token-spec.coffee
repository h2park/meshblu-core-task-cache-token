CacheToken = require '../src/cache-token'
crypto = require 'crypto'
redis  = require 'fakeredis'
uuid   = require 'uuid'

describe 'CacheToken', ->
  beforeEach ->
    @redisKey = uuid.v1()
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid
    @sut = new CacheToken
      cache: redis.createClient(@redisKey)
      pepper: 'totally-a-secret'
      uuidAliasResolver: @uuidAliasResolver
    @cache = redis.createClient @redisKey

  describe '->do', ->
    context 'when given a uuid and token', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'its-electric'
            auth:
              uuid: 'electric-eels'
              token: 'these-current-events-are-shocking!'

        @sut.do request, (error, @response) => done error

      it 'should add a hashed token to the cache', (done) ->
        hashedTheseCurrentEventsAreShocking = 'PS0AFW2LxkywNTpxMDAZHAadnN1WEzPJepW7k8BYrRY='
        @cache.exists "electric-eels:#{hashedTheseCurrentEventsAreShocking}", (error, result) =>
          expect(result).to.deep.equal 1
          done()

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'its-electric'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse

    context 'when given a different uuid and token', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'brrrr'
            auth:
              uuid: 'trapped-in-blizzard'
              token: "There's snow going back now"

        @sut.do request, (error, @response) => done error

      it 'should add a hashed token to the cache', (done) ->
        hashedTheresNoGoingBackNow = 'nRoTFqb38ZrAIJTSOPLUhnWLqK9lH2lwfrMNB25hQP4='
        @cache.exists "trapped-in-blizzard:#{hashedTheresNoGoingBackNow}", (error, result) =>
          expect(result).to.deep.equal 1
          done()

      it 'should return a 204', ->
        expectedResponse =
          metadata:
            responseId: 'brrrr'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse
