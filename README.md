exns (beta)
===========

This library allows you to interact with **Python** code from **Elixir** 

**Typical flow**

* Expose your desired Python code as a [nanoservice](https://github.com/walkr/nanoservice)
* Call your code from Elixir language using the exns library

**Features**

* Fast – uses [nanomsg](https://github.com/nanomsg/nanomsg) socket library, and MessagePack (or JSON) for serialization
* Flexible – your nanoservice can be running on the local machine or remotely on a different computer
* Simple – your Python code is just one call away

### Installation

* Add `exns` as dependency


```elixir
 defp deps do
    [{:exns, "~> 0.3.5-beta"}]
  end
```

* Ensure `exns` app is started

```elixir
  def application do
    [mod: {<<YOUR-APP-MODULE>>, []},
     applications: [..., :exns, ...]]
  end
```

### Configuration


* Define your nanoservices in your app's `config.exs`

```elixir
### Nanoservices

config :exns, nanoservices: [

  [name: :math_service,
   address: "ipc:///tmp/math-service.sock",
   timeout: 5000,
   workers: 10],

  [name: :string_service,
   address: "ipc:///tmp/string-service.sock",
   timeout: 5000,
   workers: 10,
   encoder: "msgpack"]]  # default encoder is "json"
```


### Usage

First, ensure your defined Python **nanoservices** are running.

To learn more about writing a nanoservice in Python please see the [nanoservice](https://github.com/walkr/nanoservice) library

* Making a request from Elixir

```elixir
# The call format is (serviceName, methodName, arguments)

response = Exns.call(:math_service, "add", [1, 2])

case response do
	{:ok, result} -> IO.puts "1 + 2 = #{result}"
	{:error, error} -> IO.puts "Nano service erred #{inspect error}"
end
```

* Making an optimistic request

```elixir
3 == Exns.call!(:math_service, "add", [1, 2])
```


### Development

Run tests
```
$ mix test

Stats for simple pings to math service:
---
Concurrency:                    2000 clients
Throughput                      4361 req/sec
Avg. Request Time:              0.23 ms
....

Finished in 0.6 seconds (0.1s on load, 0.4s on tests)
6 tests, 0 failures

Randomized with seed 864352
```

... and with coverage

```
$ mix test --cover
```


### MIT License
