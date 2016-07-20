Changelog
=========

### 0.3.6-beta

* Updated dependencies


### 0.3.5-beta

* Timeouts are now handled properly


### 0.3.4-beta

* Correctly match on request reference id


### 0.3.0-beta

* Accept different encoders (msgpack/json) for request workers

	```elixir
	config :exns, nanoservices: [
	  [name: :math_service,
	   ...
	   encoder: "json"]]
	```


### 0.2.0-beta

* Calls to nanoservices now return tuples (idiomatic erlang/elixir): `{:ok, result}` or `{:error, error}`
* Add optimistic `call!` function


### 0.1.0-beta

* Refactored request worker


### 0.0.2-alpha

* Handle remote service calls using poolboy workers.


### 0.0.1-alpha

* Initial commit