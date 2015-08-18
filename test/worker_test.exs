defmodule Exns.WorkerTest do
    use ExUnit.Case, async: true

    setup do
        Application.stop(:exns)
        :ok = Application.start(:exns)
    end

    test "service ping" do
        {result, error} = Exns.call("ping")
        assert {"pong", nil} == {result, error}
    end

    test "service method with args" do
        {result, error} = Exns.call("add", [1, 2])
        assert {3, nil} == {result, error}
    end

    test "service unknown method" do
        {result, error} = Exns.call("some-inexisting-method")
        assert result == nil
        assert error != nil
    end

end