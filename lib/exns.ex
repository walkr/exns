defmodule Exns do
  use Application

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

  ### ***********************************************************
  ### PUBLIC API
  ### ***********************************************************

  @doc """
  Call a remote service
  """
  def call(service, method, args \\ []) do
    make_call(service, method, args)
  end


  def call!(service, method, args \\ []) do
    {:ok, result} = make_call(service, method, args)
    result
  end

  defp make_call(service, method, args \\ [], checkout_timeout \\ 5000) do

    response = :poolboy.transaction(
      service,
      fn(worker) ->
          GenServer.call(worker, [method: method, args: args])
      end,
      checkout_timeout
    )

    # A nanoservice will return {result, error}, but in Erlang/Elixir
    # we will convert it to more idiomatic {:ok, result}, {:error, error}

    case response do
      {nil, nil} -> {:ok, nil}
      {result, nil} -> {:ok, result}
      {_, error} -> {:error, error}
    end

  end

end
