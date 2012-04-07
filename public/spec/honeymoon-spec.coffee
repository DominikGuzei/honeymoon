
Sandbox = jasmine.honeymoon.Sandbox

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