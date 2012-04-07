
describe 'jasmine.HoneyMoon.createSandbox', ->

  beforeEach -> @sinonSandboxCreateSpy = spyOn sinon.sandbox, 'create'

  it 'should setup the sinon sandbox with default values', ->
    jasmine.HoneyMoon.createSandbox()

    (expect @sinonSandboxCreateSpy).toHaveBeenCalledWithAnObjectLike
      injectInto: window
      properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
      useFakeTimers: false
      useFakeServer: false

  it 'should take and respect configuration values', ->
    testContext = {}

    jasmine.HoneyMoon.createSandbox { context: testContext, useFakeTimers: true, useFakeServer: true }

    (expect @sinonSandboxCreateSpy).toHaveBeenCalledWithAnObjectLike
      injectInto: testContext
      properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
      useFakeTimers: true
      useFakeServer: true

  it 'should save the sandbox as property on the context to be restored later', ->
    testContext = {}
    sandboxMock = {}
    @sinonSandboxCreateSpy.andReturn sandboxMock

    jasmine.HoneyMoon.createSandbox { context: testContext }

    (expect testContext._sinonSandbox).toBe sandboxMock

  it 'should not create a new sandbox if one is already present', ->
    testContext = _sinonSandbox: {}

    jasmine.HoneyMoon.createSandbox { context: testContext }

    (expect @sinonSandboxCreateSpy).not.toHaveBeenCalled()


describe 'jasmine.HoneyMoon.beforeEach', ->

  beforeEach ->
    @testContext = {}
    @originalBeforeEach = (sinon.stub window, 'beforeEach').yieldsOn @testContext
    @createSandboxSpy = spyOn jasmine.HoneyMoon, 'createSandbox'

  afterEach ->
    @originalBeforeEach.restore()


  it 'should call original beforeEach', ->
    jasmine.HoneyMoon.beforeEach ->

    (expect @originalBeforeEach.calledOnce).toBe true

  it 'should provide decorated function that sets up a sinon sandbox within context', ->
    jasmine.HoneyMoon.beforeEach ->

    (expect @createSandboxSpy).toHaveBeenCalled()
    (expect @createSandboxSpy.mostRecentCall.args[0].context).toBe @testContext

  it 'should take configuration values for sinon sandbox', ->
    configurationObject = {}
    jasmine.HoneyMoon.beforeEach configurationObject, ->

    (expect @createSandboxSpy).toHaveBeenCalledWith configurationObject

  it 'should call the custom before each function with correct context', ->
    customBeforeEachBlock = sinon.spy()

    jasmine.HoneyMoon.beforeEach customBeforeEachBlock

    (expect customBeforeEachBlock.calledOnce).toBe true
    (expect customBeforeEachBlock.thisValues[0]).toBe @testContext


describe 'jasmine.HoneyMoon.it', ->

  beforeEach ->
    @specContext = _sinonSandbox: restore: sinon.spy()
    @originalIt = sinon.stub window, 'it'
    @createSandboxStub = sinon.stub jasmine.HoneyMoon, 'createSandbox'

  afterEach ->
    @originalIt.restore()
    @createSandboxStub.restore()

  it 'should call original it function', ->
    jasmine.HoneyMoon.it()

    (expect @originalIt.calledOnce).toBe true

  it 'should hand through provided spec text', ->
    specText = "bla bla"

    jasmine.HoneyMoon.it specText

    (expect @originalIt.calledWith specText).toBe true

  it 'should call provided spec function with correct context', ->
    specFunction = sinon.spy()

    @originalIt.yieldsOn @specContext

    jasmine.HoneyMoon.it "spec text..", specFunction

    (expect specFunction.calledOnce).toBe true
    (expect specFunction.thisValues[0]).toBe @specContext

  it 'should create sinon sandbox on spec context', ->
    @originalIt.yieldsOn @specContext

    jasmine.HoneyMoon.it "spec text..", ->

    (expect @createSandboxStub.calledOnce).toBe true
    (expect @createSandboxStub.args[0][0].context).toBe @specContext

  it 'should tell the sinon sandbox to restore after executing the spec function', ->
    specFunction = sinon.spy()

    @originalIt.yieldsOn @specContext

    jasmine.HoneyMoon.it "spec text..", specFunction

    (expect specFunction.calledBefore @specContext._sinonSandbox.restore).toBe true


describe 'jasmine.HoneyMoon.overrideJasmineFunctions', ->

  beforeEach ->
    @originalBeforeEach = beforeEach
    @originalIt = it

  afterEach ->
    window.beforeEach = @originalBeforeEach
    window.it = @originalIt

  it 'should replace original beforeEach function', ->
    jasmine.HoneyMoon.overrideJasmineFunctions()

    (expect beforeEach).toBe jasmine.HoneyMoon.beforeEach
    (expect beforeEach).not.toBe @originalBeforeEach

  it 'should replace original it function', ->
    jasmine.HoneyMoon.overrideJasmineFunctions()

    (expect it).toBe jasmine.HoneyMoon.it
    (expect it).not.toBe @originalIt


describe 'jasmine.HoneyMoon.restoreJasmineFunctions', ->

  beforeEach ->
    @originalBeforeEach = beforeEach
    @originalIt = it

    jasmine.HoneyMoon.overrideJasmineFunctions()

  afterEach ->
    window.beforeEach = @originalBeforeEach
    window.it = @originalIt

  it 'should restore the original beforeEach function', ->
    jasmine.HoneyMoon.restoreJasmineFunctions()

    (expect beforeEach).toBe @originalBeforeEach

  it 'should restore the original beforeEach function', ->
    jasmine.HoneyMoon.restoreJasmineFunctions()

    (expect it).toBe @originalIt