defmodule Exns.RequestWorkerTest do
    use ExUnit.Case, async: true


    setup_all do

        # Start math service
        pid1 = spawn fn ->
            path = Path.join(System.cwd, "priv/math_service.py")
            System.cmd "python", [path]
        end

        # Start string service
        pid2 = spawn fn ->
            path = Path.join(System.cwd, "priv/string_service.py")
            System.cmd "python", [path]
        end

        # Kill processes
        on_exit fn ->
            :erlang.exit pid1, :kill
            :erlang.exit pid2, :kill
        end
    end

    setup do
        Logger.configure(level: :error)

        Application.put_env(:exns, :nanoservices,
            [[name: :math_service,
              address: "ipc:///tmp/math-test-service.sock",
              timeout: 1000,
              workers: 10,
              encoder: "msgpack"],

            [name: :unreal_service,
              address: "ipc:///tmp/no-service-here.sock",
              timeout: 1,
              workers: 10,
              encoder: "msgpack"],

            [name: :string_service,
             address: "ipc:///tmp/string-test-service.sock",
             timeout: 1000,
             workers: 10,
             encoder: "json"]]
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

    test "concurrent pings to match service and msgpack encoding" do

        max = 2000
        parent_pid = self()
        collector_pid = spawn fn-> collector(parent_pid, max) end

        started = :erlang.timestamp()

        # Launch `max` pings then collect pongs
        for _ <- 1..max, do: spawn(fn ->
            assert {:ok, "pong"} == Exns.call(:math_service, "ping")
            send collector_pid, :pong
        end)

        # Wait until all pongs are collected
        receive do
            {:done, ^max} -> :ok
        end

        IO.puts "\nStats for simple pings to math service:\n---"
        show_stats(started, max)
    end

    test "service method with args" do
        assert {:ok, 3} == Exns.call(:math_service, "add", [1, 2])
        assert {:ok, "HELLO"} == Exns.call(:string_service, "uppercase", ["hello"])
    end

    test "call!" do
        assert 3 == Exns.call!(:math_service, "add", [1,2])
    end

    test "service unknown method" do
        {:error, error} = Exns.call(:math_service, "some-inexisting-method")
        assert error != nil
    end

    test "service timeout" do
        assert {:error, :timeout} == Exns.call(:unreal_service, "add", [1,2])
    end

    # Show test statistics
    def show_stats(started, max) do

        ended = :erlang.timestamp()
        duration = :timer.now_diff(ended, started) / 1_000_000
        throughput = max / duration
        avg_req_time = Float.round(duration / max * 1000, 2)

        IO.puts String.ljust("Concurrency: ", 32) <> "#{max} clients"
        IO.puts String.ljust("Throughput", 32) <> "#{round throughput} req/sec"
        IO.puts String.ljust("Avg. Request Time: ", 32) <> "#{avg_req_time} ms"

    end

end