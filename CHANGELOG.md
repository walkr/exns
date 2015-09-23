Changelog
=========

### 0.2.0-beta

* Calls to nanoservices now return tuples (idiomatic erlang/elixir): `{:ok, result}` or `{:error, error}`
* Add optimistic `call!` function

### 0.1.0-beta

* Refactored request worker


### 0.0.2-alpha

* Handle remote service calls using poolboy workers.


### 0.0.1-alpha

* Initial commit