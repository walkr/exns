defmodule Exns.Request.Worker do

    @moduledoc """
    A Request Worker is implemented as a GenServer, which is to be spawned by poolboy.
    It's basic function is to open a socket to the remove service (on init)
    then forward

    """
    use GenServer
    require Logger

    ### ***********************************************************
    ### API
    ### ***********************************************************

    def start_link(args, opts \\ []) do
        GenServer.start_link(__MODULE__, args, opts)
    end

    ### **********
    ### CALLBACKS
    ### **********

    def init(config) do
        {:ok, socket} = new_socket(config)
        {:ok, {socket, config}}
    end

    def handle_call([method: method, args: args], _from, {socket, config} = state) do
        payload = build_payload(method, args)
        [_method, _args, ref] = payload
        send_recv(state, encode_payload(payload), ref, 10)
    end

    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    def handle_info(_info, state) do
        {:noreply, state}
    end

    def terminate(_Reason, {socket, _timeout} = state) do
        Logger.error "Worker terminated. Closing socket ..."
        :enm.close(socket)
        :ok
    end

    def code_change(_old_vsn, state, _extra) do
        {:ok, state}
    end

    ### ***********************************************************
    ### INTERNAL
    ### ***********************************************************

    def new_socket(config) do
        {:ok, socket} = :enm.req(connect: config[:address])
    end

    def new_socket(config, old_socket) do
        :enm.close(old_socket)
        new_socket(config)
    end

    defp build_payload(method, args) do
        [method, args, UUID.uuid4(:hex)]
    end

    defp encode_payload(payload) do
        {:ok, payload} = Msgpax.pack(payload)
        payload
    end

    defp decode_payload(encoded) do
        {:ok, response} = Msgpax.unpack(encoded)
        response
    end

    def send_recv(state, _encoded, _ref, 0) do
        {:reply, {:error, :no_more_retries}, state}
    end

    def send_recv({socket, config} = state, encoded, ref, retries) when retries > 0 do
        :ok = :enm.send(socket, encoded)
        case :enm.recv(socket, config[:timeout]) do

            {:ok, response} ->
                %{"result" => r, "error" => e, "ref" => ref} = decode_payload(response)
                {:reply, {r, e}, state}

            {:error, :etimedout} ->
                {:reply, :timeout, state}

            {:error, :efsm} ->
                {:ok, new_socket} = new_socket(config, socket)
                new_state = {new_socket, config}
                send_recv(new_state, encoded, ref, retries-1)
        end

    end

end