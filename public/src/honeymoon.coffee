
jasmine.honeymoon =

  Sandbox:

    originalBeforeEach: beforeEach
    originalIt: it

    create: (sandboxConfiguration={}) ->
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
        jasmine.honeymoon.Sandbox.create sandboxConfiguration
        customBeforeEachBlock.call this

      beforeEach decoratedBeforeEach

    it: (specText, specFunction) ->

      decoratedSpecFunction = ->
        jasmine.honeymoon.Sandbox.create { context: this }
        specFunction.call this
        @_sinonSandbox.restore()

      it specText, decoratedSpecFunction

    overrideJasmineFunctions: ->
      window.beforeEach = jasmine.honeymoon.Sandbox.beforeEach
      window.it = jasmine.honeymoon.Sandbox.it

    restoreJasmineFunctions: ->
      window.beforeEach = jasmine.honeymoon.Sandbox.originalBeforeEach
      window.it = jasmine.honeymoon.Sandbox.originalIt


  Matchers:

    toHaveBeenCalled: ->
      if jasmine.isSpy @actual
        jasmine.Matchers.prototype.toHaveBeenCalled.call this
      else

        unless @actual.called? and @actual.displayName?
          throw "Error in toHaveBeenCalled: Wrong argument. Jasmine or Sinon spy needed."

        @message = ->
          [
            "Expected #{@actual.displayName} to have been called at least once."
            "Expected #{@actual.displayName} not to have been called."
          ]

        return this.actual.called

    toHaveBeenCalledWith: ->
      if jasmine.isSpy @actual
        jasmine.Matchers.prototype.toHaveBeenCalledWith.apply this, arguments
      else
        expectedArgs = jasmine.util.argsToArray arguments

        unless @actual.called
          @message = ->
            [
              "Expected #{@actual.displayName} to have been called with #{jasmine.pp expectedArgs} but was never called."
              "Expected #{@actual.displayName} not to have been called with #{jasmine.pp expectedArgs} but it was."
            ]

        else
          firstCallArgs = @actual.args[0][0]
          @message = ->
            [
              "Expected #{@actual.displayName} to have been called with #{jasmine.pp expectedArgs} but it was called with #{jasmine.pp([firstCallArgs])}."
              "Expected #{@actual.displayName} not to have been called with #{jasmine.pp expectedArgs} but it was called with #{jasmine.pp([firstCallArgs])}."
            ]

        return @actual.calledWith.apply @actual, arguments
