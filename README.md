Exns (alpha)
====
Interact with Python [nanoservices](https://github.com/walkr/nanoservice) from Elixir.


## Usage

```elixir
{:ok, client} = Exns.Client.start_link(address: "ipc:///tmp/exns.sock", timeout: 1000)
{result, error} = Exns.Client.call(client, "add", [1, 2])
IO.puts "1 + 2 = #{result}"
```

## Note To Self

enm build scripts fail on OS X. Replace `cd c_src` with `cd ./c_src`.
Perhaps fork enm?
