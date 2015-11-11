defmodule Exns.Encoder do


    @moduledoc """
    MessagePack encoder using Msgspax
    """
    defmodule Msgpack do

        def encode(data) do
            {:ok, encoded} = Msgpax.pack(data)
            encoded
        end

        def decode(data) do
            {:ok, decoded} = Msgpax.unpack(data)
            decoded
        end

    end

    @moduledoc """
    JSON encoder using Poison
    """
    defmodule JSON do

        def encode(data) do
            {:ok, encoded} = Poison.encode(data)
            encoded
        end

        def decode(data) do
            {:ok, decoded} = Poison.Parser.parse(data, as: Map)
            decoded
        end

    end

    @doc """
    Encode data using using a specific encoder
    """
    def encode(data, encoder \\ "msgpack") do
        case encoder do
            "msgpack" -> Msgpack.encode(data)
            "json" -> JSON.encode(data)
        end
    end

    @doc """
    Decode data
    """
    def decode(data, encoder \\ "msgpack") do
        case encoder do
            "msgpack" -> Msgpack.decode(data)
            "json" -> JSON.decode(data)
        end
    end


end