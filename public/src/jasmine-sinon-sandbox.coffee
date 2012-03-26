
global = this

global.before = (customBeforeEachBlock, sinonConfiguration={}) ->
  
  sinonConfiguration.useFakeTimers or= false
  sinonConfiguration.useFakeServer or= false
  
  beforeEach ->
    @_sinonSandbox = sinon.sandbox.create
      injectInto: this
      properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
      useFakeTimers: sinonConfiguration.useFakeTimers
      useFakeServer: sinonConfiguration.useFakeServer
      
    customBeforeEachBlock.call this if customBeforeEachBlock?
    
global.testAndRestore = (customTestBlock) ->
  return ->
    if @_sinonSandbox?
      customTestBlock.call this
      @_sinonSandbox.restore()
    else
      wrappedCustomTestBlock = sinon.test customTestBlock
      wrappedCustomTestBlock.call this