defmodule Exns.Api do
    @moduledoc """
    This module contains the public functions of the Exns app.
    """
    defmacro __using__(_opts) do
        quote do
            import Exns.Api

            @doc ~S"""
            Call a method on a remote service
            """
            def call(service, method, args \\ []) do
                make_call(service, method, args)
            end

            @doc """
            Call a method on a remote service, but raise exception
            if remote endpoint returns an error
            """
            def call!(service, method, args \\ []) do
                {:ok, result} = make_call(service, method, args)
                result
            end
        end
    end

    def make_call(service, method, args \\ [], checkout_timeout \\ 5000) do
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
          # client has timed out
          {:error, :timeout} -> {:error, :timeout}

          # nanoservice has no errors
          {result, nil} -> {:ok, result}

          # nanoservice returned an error
          {_, error} -> {:error, error}
        end
    end

end