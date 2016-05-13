defmodule Exns.Request.Worker do

    @moduledoc """
    An `Exns.Request.Worker` is implemented as a GenServer,
    which is to be spawned by poolboy.

    Its basic function is to open a socket to the remove service (on init)
    then make requests via this socket. The socket is not closed after each
    request, but rather on the GenServer's termination.

    """
    use GenServer
    require Logger
    alias Exns.Encoder

    defmodule State do
        defstruct socket: nil, address: nil, timeout: 10, encoder: nil
    end

    ### ***********************************************************
    ### API
    ### ***********************************************************

    def start_link(args, opts \\ []) do
        GenServer.start_link(__MODULE__, args, opts)
    end

    ### **********
    ### CALLBACKS
    ### **********

    def init(opts) do
        state = %State{
            address: opts.address,
            timeout: opts.timeout,
            encoder: opts.encoder}
        {:ok, socket} = new_socket(state.address)
        state = %{state | socket: socket}
        {:ok, state}
    end

    def handle_call([method: method, args: args], _from, %{encoder: encoder} = state) do
        payload = build_payload(method, args)
        [_method, _args, ref] = payload
        send_recv(state, Encoder.encode(payload, encoder), ref, 10)
    end

    def handle_cast(_msg, state) do
        {:noreply, state}
    end

    def handle_info(_info, state) do
        {:noreply, state}
    end

    def terminate(_Reason, %{socket: socket} = _state) do
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

    def new_socket(address) do
        {:ok, socket} = :enm.req(connect: address)
        {:ok, socket}
    end

    def new_socket(address, old_socket) do
        :enm.close(old_socket)
        new_socket(address)
    end

    defp build_payload(method, args) do
        [method, args, UUID.uuid4(:hex)]
    end

    def send_recv(state, _encoded, _ref, 0) do
        {:reply, {:error, :no_more_retries}, state}
    end

    def send_recv(state, encoded, ref, retries) when retries > 0 do
        :ok = :enm.send(state.socket, encoded)
        case :enm.recv(state.socket, state.timeout) do

            {:ok, response} ->
                %{"result" => r, "error" => e, "ref" => ^ref} = Encoder.decode(response, state.encoder)
                {:reply, {r, e}, state}

            {:error, :etimedout} ->
                {:reply, {:error, :timeout}, state}

            {:error, :efsm} ->
                # Create a new socket
                {:ok, new_socket} = new_socket(state.address, state.socket)
                new_state = %{state | socket: new_socket}
                send_recv(new_state, encoded, ref, retries-1)
        end

    end

end