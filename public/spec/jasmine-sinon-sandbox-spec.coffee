
global = this

describe 'integration of sinon.js sandbox feature for Jasmine', ->
  
  describe 'sandboxed global#before', ->
  
    beforeEach ->
      @beforeEachSpy = spyOn global, 'beforeEach'
      @sinonSandboxCreateSpy = spyOn sinon.sandbox, 'create'
  
    it 'should call global#beforeEach', ->
      before()
      
      (expect @beforeEachSpy).toHaveBeenCalled()
      
    it 'should provide setup callback to beforeEach', ->
      before()
      
      (expect typeof @beforeEachSpy.mostRecentCall.args[0]).toBe 'function'
    
    
    describe 'setup callback provided to global#beforeEach', ->
          
      it 'should setup the sinon sandbox with default values', ->
        before()
        @beforeEachCallback = @beforeEachSpy.mostRecentCall.args[0]
        @beforeEachCallback()
        
        (expect @sinonSandboxCreateSpy).toHaveBeenCalledWithAnObjectLike
          injectInto: this
          properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
          useFakeTimers: false
          useFakeServer: false
          
      it 'should take and respect configuration values', ->
        before (->), useFakeTimers: true, useFakeServer: true
        @beforeEachCallback = @beforeEachSpy.mostRecentCall.args[0]
        @beforeEachCallback()

        (expect @sinonSandboxCreateSpy).toHaveBeenCalledWithAnObjectLike
          injectInto: this
          properties: ["spy", "stub", "mock", "restore", "clock", "server", "requests"]
          useFakeTimers: true
          useFakeServer: true
          
      it 'should add the sinon sandbox to current spec context', ->
        sandBoxMock = {}
        @sinonSandboxCreateSpy.andReturn sandBoxMock
        
        before()
        @beforeEachCallback = @beforeEachSpy.mostRecentCall.args[0]
        @beforeEachCallback()
      
        (expect @_sinonSandbox).toBe sandBoxMock
          
      it 'should call the custom callback provided to global#before with correct context', ->
        thisValueInCustomCallback = null
        
        customBeforeEachCallback = -> thisValueInCustomCallback = this
          
        before customBeforeEachCallback
        
        @beforeEachCallback = @beforeEachSpy.mostRecentCall.args[0]
        @beforeEachCallback()
        
        (expect thisValueInCustomCallback).toBe this
        
        
  describe 'restoring the sandboxed stubs by using global#testAndRestore', ->
    
    beforeEach -> 
      @context = _sinonSandbox: verifyAndRestore: jasmine.createSpy '_sinonSandbox.verifyAndRestore'
      @sinonTestSpy = spyOn sinon, 'test'
    
    it 'should execute the passed function with correct context', ->
      thisValueInTestBlock = null
      
      testBlockSpy = -> thisValueInTestBlock = this
        
      returnedFunction = testAndRestore testBlockSpy
      returnedFunction.call @context
      
      (expect thisValueInTestBlock).toBe @context
      
    it 'should tell sandbox to restore after custom test block was executed', ->
      returnedFunction = testAndRestore ->
      returnedFunction.call @context
      
      (expect @context._sinonSandbox.verifyAndRestore).toHaveBeenCalled()
      
    it 'should wrap the given test block with sinon.test if no sandbox is setup', ->
      thisValueInTestBlock = null
      wrappedTestBlock = -> thisValueInTestBlock = this
      
      @sinonTestSpy.andReturn wrappedTestBlock
      
      delete @context['_sinonSandbox'] 
      
      specFunction = testAndRestore wrappedTestBlock
      specFunction.call @context
      
      (expect @sinonTestSpy).toHaveBeenCalledWith wrappedTestBlock
      (expect thisValueInTestBlock).toBe @context
          
      
      
      