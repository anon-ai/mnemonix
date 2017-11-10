defmodule Mnemonix.Stores.ETS do
  @moduledoc """
  A `Mnemonix.Store` that uses an ETS table to store state.

      iex> {:ok, store} = Mnemonix.Stores.ETS.start_link
      iex> Mnemonix.put(store, "foo", "bar")
      iex> Mnemonix.get(store, "foo")
      "bar"
      iex> Mnemonix.delete(store, "foo")
      iex> Mnemonix.get(store, "foo")
      nil

  This store supports the functions in `Mnemonix.Features.Enumerable`.
  """

  alias Mnemonix.Store

  use Store.Behaviour
  use Store.Translator.Raw

  defmodule Exception do
    defexception [:message]
  end

####
# Mnemonix.Store.Behaviours.Core
##

  @doc """
  Creates a new ETS table to store state using provided `opts`.

  ## Options

  - `table`: Name of the table to create.

    - *Default:* `#{__MODULE__ |> Inspect.inspect(%Inspect.Opts{})}.Table`

  - `named`: ETS named table option

    - *Default:* `false`

    - *Notes:* If making a non-private table it's reccommened to give your table a name.

  - `privacy`: ETS privacy option - `:public | :protected | :private`

    - *Default:* `:private`

  - `heir`: ETS heir option - `{pid, any} | nil`

    - *Default:* nil

  - `concurrent`: Whether or not to optimize access for concurrent reads or writes.

    - *Allowed:* `:reads | :writes | :both | false`

    - *Default:* `false`

  - `compressed`: Whether or not to compress the values being stored.

    - *Default:* `false`

  - `initial`: A map of key/value pairs to ensure are set on the DETS table at boot.

    - *Default:* `%{}`
  """
  @impl Store.Behaviours.Core
  @spec setup(Store.options)
    :: {:ok, state :: term} | {:stop, reason :: any}
  def setup(opts) do
    table   = Keyword.get(opts, :table) || Module.concat(__MODULE__, Table)
    privacy = Keyword.get(opts, :privacy) || :private
    heir    = Keyword.get(opts, :heir) || :none
    read    = Keyword.get(opts, :concurrent, false) in [:reads, :both]
    write   = Keyword.get(opts, :concurrent, false) in [:writes, :both]

    options = [:set, privacy,
      heir: heir,
      read_concurrency: read,
      write_concurrency: write
    ]

    options = if Keyword.get(opts, :named) do
      [:named_table | options]
    else
      options
    end

    options = if Keyword.get(opts, :compressed) do
      [:compressed | options]
    else
      options
    end

    case :ets.new(table, options) do
      {:error, reason} -> {:stop, reason}
      state            -> {:ok, state}
    end
  end

####
# Mnemonix.Store.Behaviours.Map
##

  @impl Store.Behaviours.Map
  @spec delete(Store.t, Mnemonix.key)
    :: {:ok, Store.t} | Store.Behaviour.exception
  def delete(store = %Store{state: table}, key) do
    if :ets.delete(table, key) do
      {:ok, store}
    else
      {:raise, Exception,
        message: "ETS operation failed: `:ets.delete(#{table}, #{key})`"
      }
    end
  end

  @impl Store.Behaviours.Map
  @spec fetch(Store.t, Mnemonix.key)
    :: {:ok, Store.t, {:ok, Mnemonix.value} | :error} | Store.Behaviour.exception
  def fetch(store = %Store{state: table}, key) do
    case :ets.lookup(table, key) do
      [{^key, value} | []] -> {:ok, store, {:ok, value}}
      []                   -> {:ok, store, :error}
      other                -> {:raise, Exception, [reason: other]}
    end
  end

  @impl Store.Behaviours.Map
  @spec put(Store.t, Mnemonix.key, Store.value)
    :: {:ok, Store.t} | Store.Behaviour.exception
  def put(store = %Store{state: table}, key, value) do
    if :ets.insert(table, {key, value}) do
      {:ok, store}
    else
      {:raise, Exception,
        message: "ETS operation failed: `:ets.insert(#{table}, {#{key}, #{value}})`"
      }
    end
  end

####
# Mnemonix.Store.Behaviours.Enumerable
##

  @doc """
  Returns `true`: this store supports the functions in `Mnemonix.Features.Enumerable`.
  """
  @impl Store.Behaviours.Enumerable
  @spec enumerable?(Store.t)
    :: {:ok, Store.t, boolean} | Store.Behaviour.exception
  def enumerable?(store) do
    {:ok, store, true}
  end

  @impl Store.Behaviours.Enumerable
  @spec to_enumerable(Store.t)
    :: {:ok, Store.t, Enumerable.t} | Store.Behaviour.exception
  def to_enumerable(store = %Store{state: table}) do
    {:ok, store, :ets.tab2list(table)}
  end

end
