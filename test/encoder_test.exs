defmodule Exns.EncoderTests do
    use ExUnit.Case, async: true
    alias Exns.Encoder

    test "encode/decode msgpack" do
        list = ["one", 2, 3]
        encoded = Encoder.encode(list, "msgpack")
        decoded = Encoder.decode(encoded, "msgpack")
        assert list == decoded
    end

    test "encode/decode json" do
        list = ["one", 2, 3]
        encoded = Encoder.encode(list, "json")
        decoded = Encoder.decode(encoded, "json")
        assert list == decoded
    end


end