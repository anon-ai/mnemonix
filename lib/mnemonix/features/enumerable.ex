defmodule Mnemonix.Features.Enumerable do
  @name Inspect.inspect(__MODULE__, %Inspect.Opts{})

  @moduledoc """
  Functions that rely on enumerating over all key/value pairs within a store.

  Not all stores support exhaustive iteration. Consult your store's docs for more information.

  Stores that do not support enumeration will raise a `#{@name}.Exception`
  when these functions are called. You can validate that a store is enumerable before you
  invoke enumerable functions via `enumerable?/1`.

  Using this feature will define all of its Mnemonix client API functions on your module.
  Refer to `Mnemonix.Builder` for documentation on options you can use when doing so.
  """

  use Mnemonix.Behaviour
  use Mnemonix.Singleton.Behaviour

  defmodule Exception do
    defexception [:message]

    def exception(args) do
      name = Inspect.inspect(args[:module], %Inspect.Opts{})
      %__MODULE__{message: "#{name} cannot be exhaustively iterated over"}
    end
  end

  @callback enumerable?(Mnemonix.store()) :: boolean | no_return
  @doc """
  Returns `true` if the `store` is enumerable.

  Stores that return `false` will raise a `#{@name}.Exception` for other functions
  in this module.

  ## Examples

      iex> {:ok, store} = Mnemonix.start_link(Mnemonix.Stores.ETS)
      iex> #{@name}.enumerable? store
      true

      iex> {:ok, store} = Mnemonix.start_link(Mnemonix.Stores.Memcachex)
      iex> #{@name}.enumerable? store
      false
  """
  @spec enumerable?(Mnemonix.store()) :: boolean | no_return
  def enumerable?(store) do
    case GenServer.call(store, {:enumerable?}) do
      {:ok, enumerable} -> enumerable
      {:warn, message, enumerable} -> with :ok <- IO.warn(message), do: enumerable
      {:raise, type, args} -> raise type, args
    end
  end

  @callback equal?(Mnemonix.store(), Mnemonix.store()) :: boolean | no_return
  @doc """
  Checks that contents of stores `store1` and `store2` are equal.

  Two stores are considered to be equal if they contain the same keys and those keys contain the same values.

  ## Examples

      iex> store1 = Mnemonix.new(%{a: 1})
      iex> store2 = Mnemonix.new(%{a: 1})
      iex> #{@name}.equal?(store1, store2)
      true

      iex> store1 = Mnemonix.new(%{a: 1})
      iex> store2 = Mnemonix.new(%{a: 2})
      iex> #{@name}.equal?(store1, store2)
      false

      iex> store1 = Mnemonix.new(%{a: 1})
      iex> store2 = Mnemonix.new(%{b: 2})
      iex> #{@name}.equal?(store1, store2)
      false

  ## Notes

  If `enumerable?/1` returns `false` for either store then this function will raise a `#{@name}.Exception`.

  Depending on the underlying store types this function may be very inefficient.
  """
  @spec equal?(Mnemonix.store(), Mnemonix.store()) :: boolean | no_return
  def equal?(store1, store2) do
    result1 = case GenServer.call(store1, {:to_enumerable}) do
      {:ok, result1} -> result1
      {:warn, message, result1} -> with :ok <- IO.warn(message), do: result1
      {:raise, type, args} -> raise type, args
    end
    result2 = case GenServer.call(store2, {:to_enumerable}) do
      {:ok, result2} -> result2
      {:warn, message, result2} -> with :ok <- IO.warn(message), do: result2
      {:raise, type, args} -> raise type, args
    end
    result1 === result2
  end

  @callback keys(Mnemonix.store()) :: [Mnemonix.key()] | no_return
  @doc """
  Returns all keys in `store`.

  If `enumerable?/1` returns false then this function will raise a `#{@name}.Exception`.

  ## Examples

      iex> #{@name}.keys(Mnemonix.new(%{a: 1, b: 2}))
      [:a, :b]

      iex> #{@name}.keys(Mnemonix.new)
      []

  ## Notes

  If `enumerable?/1` returns false then this function will raise a `#{@name}.Exception`.

  Depending on the underlying store this function may be very inefficient.
  """
  @spec keys(Mnemonix.store()) :: [Mnemonix.key()] | no_return
  def keys(store) do
    case GenServer.call(store, {:keys}) do
      {:ok, keys} -> keys
      {:warn, message, keys} -> with :ok <- IO.warn(message), do: keys
      {:raise, type, args} -> raise type, args
    end
  end

  @callback to_list(Mnemonix.store()) :: [{Mnemonix.key(), Mnemonix.value()}] | no_return
  @doc """
  Returns all key/value pairs in `store` as a list of two-tuples.

  If `enumerable?/1` returns false then this function will raise a `#{@name}.Exception`.

  ## Examples

      iex> #{@name}.to_list(Mnemonix.new(%{a: 1, b: 2}))
      [a: 1, b: 2]

      iex> #{@name}.to_list(Mnemonix.new(%{"foo" => "bar"}))
      [{"foo", "bar"}]

      iex> #{@name}.to_list(Mnemonix.new)
      []

      iex> {:ok, store} = Mnemonix.start_link(Mnemonix.Stores.Memcachex)
      iex> #{@name}.to_list(store)
      ** (#{@name}.Exception) Mnemonix.Stores.Memcachex cannot be exhaustively iterated over

  ## Notes

  If `enumerable?/1` returns false then this function will raise a `#{@name}.Exception`.

  Depending on the underlying store this function may be very inefficient.
  """
  @spec to_list(Mnemonix.store()) :: [{Mnemonix.key(), Mnemonix.value()}] | no_return
  def to_list(store) do
    case GenServer.call(store, {:to_list}) do
      {:ok, list} -> list
      {:warn, message, list} -> with :ok <- IO.warn(message), do: list
      {:raise, type, args} -> raise type, args
    end
  end

  @callback values(Mnemonix.store()) :: [Mnemonix.value()] | no_return
  @doc """
  Returns all values in `store`.

  If `enumerable?/1` returns false then this function will raise a `#{@name}.Exception`.

  ## Examples

      iex> #{@name}.values(Mnemonix.new(%{a: 1, b: 2}))
      [1, 2]
      iex> #{@name}.values(Mnemonix.new)
      []

  ## Notes

  If `enumerable?/1` returns false then this function will raise a `#{@name}.Exception`.

  Depending on the underlying store this function may be very inefficient.
  """
  @spec values(Mnemonix.store()) :: [Mnemonix.value()] | no_return
  def values(store) do
    case GenServer.call(store, {:values}) do
      {:ok, values} -> values
      {:warn, message, values} -> with :ok <- IO.warn(message), do: values
      {:raise, type, args} -> raise type, args
    end
  end
end
