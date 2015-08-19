defmodule Exns.WorkerTest do
    use ExUnit.Case, async: true

    setup do
        Application.stop(:exns)
        :ok = Application.start(:exns)
    end

    test "service ping" do
        {r1, e1} = Exns.call(:math_service, "ping")
        assert {"pong", nil} == {r1, e1}

        {r2, e2} = Exns.call(:string_service, "ping")
        assert {"pong", nil} == {r2, e2}
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