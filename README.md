exns (beta)
===========

Interact with Python [nanoservices](https://github.com/walkr/nanoservice) from Elixir.


### Usage


* Update your app's `config.exs` with your nanoservices

```elixir
config :exns, nanoservices: [

  [name: :math_service,
   address: "ipc:///tmp/math-service.sock",
   timeout: 5000,
   workers: 10],

  [name: :string_service,
   address: "ipc:///tmp/string-service.sock",
   timeout: 5000,
   workers: 10,
   encoder: "msgpack"]]
```


* Make calls to a nanoservice

```elixir
# Successful request
{:ok, result} = Exns.call(:math_service, "add", [1, 2])
IO.puts "1 + 2 = #{result}"

# Optimistic request
3 == Exns.call!(:math_service, "add", [1, 2])

# A request which erred on the python side
{:error, error} = Exns.call(:math_service, "your_non_existing_method")
```


### Development

Run tests
```
$ mix test
```

... and with coverage

```
$ mix test --cover
```


### MIT License
