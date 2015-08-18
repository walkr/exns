defmodule Exns.ClientTest do
    use ExUnit.Case, async: true

    setup do
        {:ok, client} = Exns.Client.start_link(address: "ipc:///tmp/exns.sock", timeout: 1000)
        {:ok, client: client}
    end

    test "service ping", %{client: client} do
        {result, error} = Exns.Client.call(client, "ping")
        assert result == "pong"
        assert error == nil
    end

    test "service method with args", %{client: client} do
        {result, error} = Exns.Client.call(client, "add", [1, 2])
        assert result == 3
        assert error == nil
    end

    test "service unknown method", %{client: client} do
        {result, error} = Exns.Client.call(client, "some-inexisting-method")
        assert result == nil
        assert error != nil
    end

end