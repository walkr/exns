defmodule Exns.Client do

    use GenServer

    ### ===========================================================
    ### Client
    ### ===========================================================

    def start_link(args, opts \\ []) do
        GenServer.start_link(__MODULE__, args, opts)
    end


    def call(client, method, args \\ []) do
        GenServer.call(client, [method: method, args: args])
    end


    ### ===========================================================
    ### Server
    ### ===========================================================

    defp build_payload(method, args) do
        [method, args, UUID.uuid4(:hex)]
    end

    defp encode_payload(payload) do
        {:ok, payload} = Msgpax.pack(payload)
        payload
    end

    def decode_payload(encoded) do
        {:ok, response} = Msgpax.unpack(encoded)
        response
    end

    def init(address: address, timeout: timeout) do
        {:ok, socket} = :enm.req(connect: address)
        {:ok, {socket, timeout}}
    end

    def handle_call([method: method, args: args], _from, {socket, timeout} = state) do
        payload = build_payload(method, args)
        [_method, _args, ref] = payload

        encoded = encode_payload(payload)
        :ok = :enm.send(socket, encoded)

        case :enm.recv(socket, timeout) do
            {:ok, response} ->
                %{"result" => r, "error" => e, "ref" => rf} = decode_payload(response)
                {:reply, {r, e}, state}
            {:error, :etimedout} ->
                {:reply, {:timeout, nil}, state}
        end
    end

end