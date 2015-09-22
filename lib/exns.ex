defmodule Exns do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    nanoservices = Application.get_env(:exns, :nanoservices)

    children = Enum.map(nanoservices, fn(ns) ->
      pool_name = ns[:name]

      pool_args = [
        name: {:local, pool_name},
        worker_module: Exns.Worker,
        size: ns[:workers]]

      worker_args = [
        address: ns[:address],
        timeout: ns[:timeout]]

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
    checkout_timeout = 5000
    :poolboy.transaction(
      service,
      fn(worker) ->
          GenServer.call(worker, [method: method, args: args])
      end,
      checkout_timeout
    )
  end


  def subscribe(service, pattern) do
  end

end
