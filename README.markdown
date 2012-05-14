Advanced Sinon.js integration for the Jasmine BDD Framework
===========================================================

HoneyMoon provides integration of sinon.js in two main areas:

1. Sandboxing
-------------
HoneyMoon replaces the default `beforeEach` and `it` functions of jasmine to inject a
sinon.js sandbox and all sinon.js methods like `sinon.spy`, and `sinon.fakeServer`.

### Sinon functions in spec context


```coffeescript
beforeEach { useFakeServer: true }, -> # injects 'server' into spec context
  @server.respondWith ... # use fake server as expected

it 'should test something with fake server', ->
  # ...
  
  @server.respond()
  
  # server is automatically restored after your spec
```

beforeEach takes an **optional** configuration object like:

```coffeescript
beforeEach
  { 
    useFakeServer: true # injects fake server as '@server' default = false
    useFakeTimers: true # injects fake timers as '@clock' default = false
  }, ->

```

### Automatic Restoring of Spies / Stubs / Mocks and everything else

Normally sinon.js requires you to call `myStub.restore()` to restore a previously stubbed method. 
HoneyMoon does this automatically by wrapping all specs with a sinon.js sandbox.

```coffeescript
beforeEach -> @jQueryAjaxStub = @stub jQuery, 'ajax'

it 'should test something related with jquery ajax', ->
  # ... test code
  
  # jQuery.ajax is automatically restored after each spec
```

All functions available:

```coffeescript
beforeEach ->
  @spy object, 'methodName'
  @stub object, 'methodName'
  @mock object
  @server # fake server
  @requests # requests of fake server
  @clock # fake timers

```

### 2. Advanced Matchers for Sinon

Other integration projects like [jasmine-sinon](https://github.com/froots/jasmine-sinon) replace the default matchers
of jasmine with primitive custom matchers for sinon. The problem is that they don't play nicely with existing projects
that already use standard jasmine spies. The other problem is that their error messages are not really speaking and
don't provide enough information to be useful.

With HoneyMoon you can use jasmine spies side by side with sinon spies / stubs / mocks:

```coffeescript
beforeEach -> 
  spyOn object, 'methodName'
  @jQueryAjaxStub = @stub jQuery, 'ajax'

it 'should allow the use of jasmine and sinon spies side by side', ->
  # ... test code
  
  (expect object.methodName).toHaveBeenCalled() # jasmine spy
  (expect jQuery.ajax).toHaveBeenCalled() # sinon stub
  
```

HoneyMoon currently provides these matchers for sinon spies / stubs / mocks:

```coffeescript

# call count
(expect @mySinonSpy).toHaveBeenCalled()
(expect @mySinonSpy).toHaveBeenCalledTwice()
(expect @mySinonSpy).toHaveBeenCalledThrice()
(expect @mySinonSpy).toHaveBeenCalledTimes 9

# call parameters
(expect @mySinonSpy).toHaveBeenCalledWith param1, param2

```

and of course all matchers also work with `.not.`


The MIT License (MIT)
Copyright (c) 2012 [NerdKitchen](http://nerdkitchen.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.