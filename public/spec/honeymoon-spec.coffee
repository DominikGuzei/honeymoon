
Sandbox = jasmine.honeymoon.Sandbox
Matchers = jasmine.honeymoon.Matchers

describe 'jasmine.honeymoon.Sandbox.create', ->

  beforeEach -> @sinonSandboxCreateSpy = spyOn sinon.sandbox, 'create'

  it 'should setup the sinon sandbox with default values', ->
    Sandbox.create()

    (expect @sinonSandboxCreateSpy).toHaveBeenCalledWithAnObjectLike
      injectInto: window
      properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
      useFakeTimers: false
      useFakeServer: false

  it 'should take and respect configuration values', ->
    testContext = {}

    Sandbox.create { context: testContext, useFakeTimers: true, useFakeServer: true }

    (expect @sinonSandboxCreateSpy).toHaveBeenCalledWithAnObjectLike
      injectInto: testContext
      properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
      useFakeTimers: true
      useFakeServer: true

  it 'should save the sandbox as property on the context to be restored later', ->
    testContext = {}
    sandboxMock = {}
    @sinonSandboxCreateSpy.andReturn sandboxMock

    Sandbox.create { context: testContext }

    (expect testContext._sinonSandbox).toBe sandboxMock

  it 'should not create a new sandbox if one is already present', ->
    testContext = _sinonSandbox: {}

    Sandbox.create { context: testContext }

    (expect @sinonSandboxCreateSpy).not.toHaveBeenCalled()


describe 'jasmine.honeymoon.Sandbox.beforeEach', ->

  beforeEach ->
    @testContext = {}
    @originalBeforeEach = (sinon.stub window, 'beforeEach').yieldsOn @testContext
    @createSandboxSpy = spyOn Sandbox, 'create'

  afterEach ->
    @originalBeforeEach.restore()


  it 'should call original beforeEach', ->
    Sandbox.beforeEach ->

    (expect @originalBeforeEach.calledOnce).toBe true

  it 'should provide decorated function that sets up a sinon sandbox within context', ->
    Sandbox.beforeEach ->

    (expect @createSandboxSpy).toHaveBeenCalled()
    (expect @createSandboxSpy.mostRecentCall.args[0].context).toBe @testContext

  it 'should take configuration values for sinon sandbox', ->
    configurationObject = {}

    Sandbox.beforeEach configurationObject, ->

    (expect @createSandboxSpy).toHaveBeenCalledWith configurationObject

  it 'should call the custom before each function with correct context', ->
    customBeforeEachBlock = sinon.spy()

    Sandbox.beforeEach customBeforeEachBlock

    (expect customBeforeEachBlock.calledOnce).toBe true
    (expect customBeforeEachBlock.thisValues[0]).toBe @testContext


describe 'jasmine.honeymoon.Sandbox.it', ->

  beforeEach ->
    @specContext = _sinonSandbox: restore: sinon.spy()
    @originalIt = sinon.stub window, 'it'
    @createSandboxStub = sinon.stub Sandbox, 'create'

  afterEach ->
    @originalIt.restore()
    @createSandboxStub.restore()

  it 'should call original it function', ->
    Sandbox.it()

    (expect @originalIt.calledOnce).toBe true

  it 'should hand through provided spec text', ->
    specText = "bla bla"

    Sandbox.it specText

    (expect @originalIt.calledWith specText).toBe true

  it 'should call provided spec function with correct context', ->
    specFunction = sinon.spy()

    @originalIt.yieldsOn @specContext

    Sandbox.it "spec text..", specFunction

    (expect specFunction.calledOnce).toBe true
    (expect specFunction.thisValues[0]).toBe @specContext

  it 'should create sinon sandbox on spec context', ->
    @originalIt.yieldsOn @specContext

    Sandbox.it "spec text..", ->

    (expect @createSandboxStub.calledOnce).toBe true
    (expect @createSandboxStub.args[0][0].context).toBe @specContext

  it 'should tell the sinon sandbox to restore after executing the spec function', ->
    specFunction = sinon.spy()

    @originalIt.yieldsOn @specContext

    Sandbox.it "spec text..", specFunction

    (expect specFunction.calledBefore @specContext._sinonSandbox.restore).toBe true


describe 'jasmine.honeymoon.Sandbox.overrideJasmineFunctions', ->

  beforeEach ->
    @originalBeforeEach = beforeEach
    @originalIt = it

  afterEach ->
    window.beforeEach = @originalBeforeEach
    window.it = @originalIt

  it 'should replace original beforeEach function', ->
    Sandbox.overrideJasmineFunctions()

    (expect beforeEach).toBe Sandbox.beforeEach
    (expect beforeEach).not.toBe @originalBeforeEach

  it 'should replace original it function', ->
    Sandbox.overrideJasmineFunctions()

    (expect it).toBe Sandbox.it
    (expect it).not.toBe @originalIt


describe 'jasmine.HoneyMoon.restoreJasmineFunctions', ->

  beforeEach ->
    @originalBeforeEach = beforeEach
    @originalIt = it

    Sandbox.overrideJasmineFunctions()

  afterEach ->
    window.beforeEach = @originalBeforeEach
    window.it = @originalIt

  it 'should restore the original beforeEach function', ->
    Sandbox.restoreJasmineFunctions()

    (expect beforeEach).toBe @originalBeforeEach

  it 'should restore the original beforeEach function', ->
    Sandbox.restoreJasmineFunctions()

    (expect it).toBe @originalIt


describe 'matcher integration of sinon into jasmine', ->

  matcherPrototypes = jasmine.Matchers.prototype

  describe 'toHaveBeenCalled', ->

    beforeEach ->
      sinon.stub matcherPrototypes, 'toHaveBeenCalled'

    afterEach ->
      matcherPrototypes.toHaveBeenCalled.restore()


    it 'should call prototype of original matcher when jasmine spy is given', ->
      expectContext = actual: jasmine.createSpy()

      Matchers.toHaveBeenCalled.call expectContext

      (expect matcherPrototypes.toHaveBeenCalled.calledOnce).toBe true
      (expect matcherPrototypes.toHaveBeenCalled.thisValues[0]).toBe expectContext

    it 'should not call original matcher when sinon spy is used', ->
      Matchers.toHaveBeenCalled.call actual: sinon.spy()

      (expect matcherPrototypes.toHaveBeenCalled.called).toBe false

    it 'should handle messages for sinon spies', ->
      expectContext = actual: sinon.spy()
      Matchers.toHaveBeenCalled.call expectContext

      (expect expectContext.message()[0]).toBe "Expected #{expectContext.actual.displayName} to have been called at least once."
      (expect expectContext.message()[1]).toBe "Expected #{expectContext.actual.displayName} not to have been called."

    it 'should return false when sinon spy was not called', ->
      matcherResult = Matchers.toHaveBeenCalled.call actual: sinon.spy()

      (expect matcherResult).toBe false

    it 'should return true when sinon spy was called', ->
      calledSpy = sinon.spy()
      calledSpy()

      matcherResult = Matchers.toHaveBeenCalled.call actual: calledSpy

      (expect matcherResult).toBe true

    it 'should throw error when wrong argument was provided', ->
      callWithWrongArgument = -> Matchers.toHaveBeenCalled.call actual: {}

      (expect callWithWrongArgument).toThrow()


  describe 'toHaveBeenCalledWith', ->

    beforeEach ->
      sinon.stub matcherPrototypes, 'toHaveBeenCalledWith'

    afterEach ->
      matcherPrototypes.toHaveBeenCalledWith.restore()


    it 'should call prototype of original matcher when jasmine spy is given', ->
      expectContext = actual: jasmine.createSpy()
      first = {}
      second = {}

      Matchers.toHaveBeenCalledWith.call expectContext, first, second

      (expect matcherPrototypes.toHaveBeenCalledWith.calledWith first, second).toBe true
      (expect matcherPrototypes.toHaveBeenCalledWith.thisValues[0]).toBe expectContext

    it 'should not call original matcher when sinon spy is used', ->
      Matchers.toHaveBeenCalledWith.call actual: sinon.spy()

      (expect matcherPrototypes.toHaveBeenCalledWith.called).toBe false

    it 'should handle messages when spy was called/not called', ->
      expectContext = actual: sinon.spy()
      parameter = "test paramters"

      Matchers.toHaveBeenCalledWith.call expectContext, parameter

      (expect expectContext.message()[0]).toBe "Expected #{expectContext.actual.displayName} to have been called with #{jasmine.pp([parameter])} but was never called."
      (expect expectContext.message()[1]).toBe "Expected #{expectContext.actual.displayName} not to have been called with #{jasmine.pp([parameter])} but it was."

    it 'should handle messages when spy was called/not called with correct arguments', ->
      expectContext = actual: sinon.spy()
      usedArgument = {}
      expectedArgument = {}

      expectContext.actual usedArgument # call spy
      Matchers.toHaveBeenCalledWith.call expectContext, expectedArgument

      (expect expectContext.message()[0]).toBe "Expected #{expectContext.actual.displayName} to have been called with #{jasmine.pp([expectedArgument])} but it was called with #{jasmine.pp([usedArgument])}."
      (expect expectContext.message()[1]).toBe "Expected #{expectContext.actual.displayName} not to have been called with #{jasmine.pp([expectedArgument])} but it was called with #{jasmine.pp([usedArgument])}."

    it 'should return false when sinon spy was not called with correct arguments', ->
      matcherResult = Matchers.toHaveBeenCalledWith.call actual: sinon.spy(), "needed param"

      (expect matcherResult).toBe false

    it 'should return true when sinon spy was called with correct arguments', ->
      calledSpy = sinon.spy()
      first = ""
      second = {}

      calledSpy first, second

      matcherResult = Matchers.toHaveBeenCalledWith.call { actual: calledSpy }, first, second

      (expect matcherResult).toBe true