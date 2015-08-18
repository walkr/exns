defmodule Exns do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    pool_name = Application.get_env(:exns, :pool_name)
    pool_args = [
        name: {:local, pool_name},
        worker_module: Exns.Worker,
        size: Application.get_env(:exns, :pool_size)]
    worker_args = [
        address: Application.get_env(:exns, :service_address),
        timeout: Application.get_env(:exns, :service_timeout)]
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Exns.Worker, [arg1, arg2, arg3])
      :poolboy.child_spec(pool_name, pool_args, worker_args)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exns.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Call a remote service
  """
  def call(method, args \\ []) do
    pool_name = Application.get_env(:exns, :pool_name)
    checkout_timeout = 3000

   :poolboy.transaction(
        pool_name,
        fn(worker) ->
            GenServer.call(worker, [method: method, args: args]) end,
        checkout_timeout
    )
  end

end
