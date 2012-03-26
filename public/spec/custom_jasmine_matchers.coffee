beforeEach ->
  @addMatchers
    toHaveBeenCalledWithAnObjectLike: (expectedObject) ->
      unless @actual.mostRecentCall.args[0]?
        throw "Expected spy '#{this.actual.identity}' to have been called with an object but was not."
      
      @env.equals_ @actual.mostRecentCall.args[0], expectedObject