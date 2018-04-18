# apixiom

This library to make simple JSON api for your app using cowboy 2 as webserver.
Also it use lager for logging and JSX for JSON parsing and constructing.
Also there is a experemental option with msgpack packer.
You have to add your favorite version of cowboy, jsx, lager and jsx to your project.

Tested with such conf

```
{deps, [
        {lager, "3.5.2"},
        {cowboy, "2.1.0"},
        {jsx, "2.8.3"},
        {msgpack, {git, "https://github.com/msgpack/msgpack-erlang", "master"}}
       ]}.
```


To run apixiom I recommend add childspec to you top supervisor (see childspec
example in examples/myapp_http.erl). Also you have to add handlers (see example 
handlers in examples/myapp_httpapi.erl)
