
jasmine.HoneyMoon =

  originalBeforeEach: beforeEach
  originalIt: it

  createSandbox: (sandboxConfiguration={}) ->
    sandboxConfiguration.context ?= window
    sandboxConfiguration.useFakeTimers ?= false
    sandboxConfiguration.useFakeServer ?= false

    context = sandboxConfiguration.context

    # don't override existing sandbox
    return if context._sinonSandbox?

    context._sinonSandbox = sinon.sandbox.create
      injectInto: context
      properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
      useFakeTimers: sandboxConfiguration.useFakeTimers
      useFakeServer: sandboxConfiguration.useFakeServer

  beforeEach: (sandboxConfiguration, customBeforeEachBlock) ->

    # no sandbox configuration provided
    if arguments.length is 1 then customBeforeEachBlock = arguments[0]

    decoratedBeforeEach = ->
      sandboxConfiguration.context = this
      jasmine.HoneyMoon.createSandbox sandboxConfiguration
      customBeforeEachBlock.call this

    beforeEach decoratedBeforeEach

  it: (specText, specFunction) ->

    decoratedSpecFunction = ->
      jasmine.HoneyMoon.createSandbox { context: this }
      specFunction.call this
      @_sinonSandbox.restore()

    it specText, decoratedSpecFunction

  overrideJasmineFunctions: ->
    window.beforeEach = jasmine.HoneyMoon.beforeEach
    window.it = jasmine.HoneyMoon.it

  restoreJasmineFunctions: ->
    window.beforeEach = jasmine.HoneyMoon.originalBeforeEach
    window.it = jasmine.HoneyMoon.originalIt