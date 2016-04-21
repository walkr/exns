defmodule Exns do
  @moduledoc ~S"""
  Communicate with your [python nanoservices](https://github.com/walkr/nanoservice)
  from Elixir.

  ## Installation

  Add `exns` as a dependency to your project's `mix.exs`

      def deps do
        [{:exns, "~> 0.3.3"}]
      end

  ## Configuration

  In your application's `config.exs` describe your nanoservices like so:

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

  ## Communication with a nanoservice


  Say you have the following nanoservice in Python:

      from nanoservice import Responder

      def add(x, y):
          return x+y

      s = Responder('ipc:///tmp/math_service.sock')
      s.register('add', add)
      s.start()

  To call your nanoservice from Elixir you'd use:

      case Exns.call("math_service", "add", [1,2]) do
          {:ok, result} -> IO.puts "Result is: #{result}"
          {:error, msg} -> IO.puts "Error #{msg}"
      end

  OR
      result = Exns.call!("math_service", "add", [1,2])

  """

  use Application
  use Exns.Api

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    nanoservices = Application.get_env(:exns, :nanoservices, [])

    children = Enum.map(nanoservices, fn(ns) ->
      pool_name = ns[:name]

      pool_args = [
        name: {:local, pool_name},
        worker_module: Exns.Request.Worker,
        size: ns[:workers]]

      worker_args = %{
        address: ns[:address],
        timeout: ns[:timeout],
        encoder: ns[:encoder] || "json"
      }

      :poolboy.child_spec(pool_name, pool_args, worker_args)
    end)

    opts = [strategy: :one_for_one, name: Exns.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
