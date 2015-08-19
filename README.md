Exns (alpha)
====
Interact with Python [nanoservices](https://github.com/walkr/nanoservice) from Elixir.


### Usage

* Define nanoservices in mix.exs

```elixir
def application do
    [applications: [:exns],
     env: [
        nanoservices: [
            [name: :math_service,
             address: "ipc:///tmp/math-service.sock",
             timeout: 1000,
             workers: 10
            ]
     ]
    ]
```

* Then simply call the nanoservice

```
{result, error} = Exns.call(:math_service, "add", [1, 2]
IO.puts "1 + 2 = #{result}"
```


(*) __Note To Self:__ enm build scripts fail on OS X. Replace `cd c_src` with `cd ./c_src`. Perhaps fork enm?

MIT LICENSE
