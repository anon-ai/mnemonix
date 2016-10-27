defmodule Mnemonix.Store do
  @moduledoc """
  Container for store state that defers core store operations to an adapter.
  """
  
  @enforce_keys [:adapter]
  defstruct adapter: nil, opts: [], state: nil
  @type t :: %__MODULE__{adapter: adapter, opts: opts, state: state}
  
  defmacro __using__(_) do
    quote location: :keep do
      use Mnemonix.Store.Behaviour
    end
  end
  
  @type adapter :: Atom.t
  @type opts    :: Keyword.t
  @type state   :: any
  
  @type key   :: any
  @type value :: any
  @type ttl   :: non_neg_integer
  
  @type keys   :: [key] | []
  @type values :: [value] | []
  
  @spec start_link(adapter)                            :: GenServer.on_start
  @spec start_link(adapter, GenServer.options)         :: GenServer.on_start
  @spec start_link({adapter, opts})                    :: GenServer.on_start
  @spec start_link({adapter, opts}, GenServer.options) :: GenServer.on_start
  
  def start_link(init, opts \\ [])
  def start_link(adapter, opts) when not is_tuple adapter do
    start_link {adapter, []}, opts
  end
  def start_link(init, opts) do
    GenServer.start_link(__MODULE__, init, opts)
  end
  
  use GenServer

  @spec init({adapter, opts}) ::
    {:ok, state} |
    {:ok, state, timeout | :hibernate} |
    :ignore |
    {:stop, reason :: any}
    
  def init({adapter, opts}) do
    case adapter.init(opts) do
      {:ok, state}          -> {:ok, %__MODULE__{adapter: adapter, opts: opts, state: state} }
      {:ok, state, timeout} -> {:ok, %__MODULE__{adapter: adapter, opts: opts, state: state}, timeout }
      other                 -> other
    end
  end
  
  @spec init({adapter, opts})  ::
    {:reply, reply, new_state} |
    {:reply, reply, new_state, timeout | :hibernate} |
    {:noreply, new_state} |
    {:noreply, new_state, timeout | :hibernate} |
    {:stop, reason, reply, new_state} |
    {:stop, reason, new_state} when reply: term, new_state: state, reason: term
    
####  
# CORE
##
  
  def handle_call({:delete, key}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.delete(store, key) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end

  def handle_call({:expires, key, time}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.expires(store, key, time) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:fetch, key}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.fetch(store, key) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
    
  def handle_call({:keys}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.keys(store) do
      {:ok, store, keys}   -> {:reply, {:ok, keys}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end

  def handle_call({:put, key, value}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.put(store, key, value) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end

####  
# MAP FUNCTIONS
##
  
  def handle_call({:drop, keys}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.drop(store, keys) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:fetch!, key}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.fetch!(store, key) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:get, key}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.get(store, key) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:get, key, default}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.get(store, key, default) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:get_and_update, key, fun}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.get_and_update(store, key, fun) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:get_and_update!, key, fun}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.get_and_update!(store, key, fun) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:get_lazy, key, fun}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.get_lazy(store, key, fun) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:has_key?, key}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.has_key?(store, key) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:pop, key}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.pop(store, key) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:pop, key, default}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.pop(store, key, default) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:pop_lazy, key, fun}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.pop_lazy(store, key, fun) do
      {:ok, store, value}  -> {:reply, {:ok, value}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:put_new, key, value}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.put_new(store, key, value) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:put_new_lazy, key, fun}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.put_new_lazy(store, key, fun) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:update, key, initial, fun}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.update(store, key, initial, fun) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
  def handle_call({:update!, key, fun}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.update!(store, key, fun) do
      {:ok, store}         -> {:reply, :ok, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
    
  def handle_call({:values}, _, store = %__MODULE__{adapter: adapter}) do
    case adapter.values(store) do
      {:ok, store, values} -> {:reply, {:ok, values}, store}
      {:raise, type, args} -> {:reply, {:raise, type, args}, store}
    end
  end
  
end