defmodule Exns.RequestWorkerTest do
    use ExUnit.Case, async: true


    setup do
        Application.put_env(:exns, :nanoservices,
            [[name: :math_service,
              address: "ipc:///tmp/math-service.sock",
              timeout: 1000,
              workers: 10],

            [name: :string_service,
             address: "ipc:///tmp/string-service.sock",
             timeout: 1000,
             workers: 10]]
        )

        Application.stop(:exns)
        :ok = Application.start(:exns)
    end


    # *********************
    # PONG COLLECTOR
    # *********************

    def collector(parent, total) do
        collector(parent, total, 0)
    end

    def collector(parent, total, total) do
        send parent, {:done, total}
    end

    def collector(parent, total, acc) do
        receive do
            :pong -> collector(parent, total, acc + 1)
        end
    end


    # *********************
    # TESTS
    # *********************

    test "concurrent pings to service" do

        max = 5000
        parent_pid = self()
        collector_pid = spawn fn-> collector(parent_pid, max) end

        started = :erlang.timestamp()

        # Launch `max` pings then collect pongs
        for _ <- 1..max, do: spawn(fn ->
            response = Exns.call(:math_service, "ping")
            {"pong", nil} = response
            assert {"pong", nil} == response
            send collector_pid, :pong
        end)

        # Wait until all pongs are collected
        receive do
            {:done, ^max} -> :ok
        end

        ended = :erlang.timestamp()
        duration = :timer.now_diff(ended, started) / 1_000_000
        throughput = max / duration

        IO.puts "Service performance: #{throughput} reqs/sec"

    end

    test "service method with args" do
        {result, error} = Exns.call(:math_service, "add", [1, 2])
        assert {3, nil} == {result, error}

        {result, error} = Exns.call(:string_service, "uppercase", ["hello"])
        assert {"HELLO", nil} == {result, error}
    end

    test "service unknown method" do
        {result, error} = Exns.call(:math_service, "some-inexisting-method")
        assert result == nil
        assert error != nil
    end

end