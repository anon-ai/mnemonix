defmodule Mnemonix.Features.Bump do
  @moduledoc """
  Functions to increment/decrement integer values within a store.

  All of these functions are available on the main `Mnemonix` module.
  """ && false

  use Mnemonix.Behaviour
  use Mnemonix.Singleton.Behaviour

  @typedoc """
  The value of a bump operation.
  """
  @type amount :: integer

  @typedoc """
  The return value of a bump operation.
  """
  @type result :: :ok | {:error, :no_integer}

  @doc """
  Adds `amount` to the value of the integer entry under `key` in `store`.

  If the `key` does not exist, it is set to `0` before performing the operation.

  If the `amount` or the value under `key` is not an integer,
  returns `{:error, :no_integer}`, otherwise returns `:ok`,
  and the value will remain unchanged.

  ## Examples

      iex> store = Mnemonix.new(%{a: 1})
      iex> Mnemonix.bump(store, :a, 1)
      :ok
      iex> Mnemonix.get(store, :a)
      2

      iex> store = Mnemonix.new
      iex> Mnemonix.bump(store, :b, 2)
      :ok
      iex> Mnemonix.get(store, :b)
      2

      iex> store = Mnemonix.new(%{c: "foo"})
      iex> Mnemonix.bump(store, :c, 3)
      {:error, :no_integer}

      iex> store = Mnemonix.new
      iex> Mnemonix.bump(store, :c, "foo")
      {:error, :no_integer}
  """
  @callback bump(Mnemonix.store, Mnemonix.key, amount :: term)
    :: result | no_return
  @spec bump(Mnemonix.store, Mnemonix.key, amount :: term)
    :: result | no_return
  def bump(store, key, amount) do
    case GenServer.call(store, {:bump, key, amount}) do
      :ok                  -> :ok
      {:raise, type, args} -> raise type, args
    end
  end

  @doc """
  Adds `amount` to the value of the integer entry under `key` in `store`.

  If the `key` does not exist, it is set to `0` before performing the operation.

  If the `amount` or the value under `key` is not an integer, raises an `ArithmeticError`,
  and the value will remain unchanged.

  ## Examples

      iex> store = Mnemonix.new(%{a: 1})
      iex> Mnemonix.bump!(store, :a, 2)
      :ok
      iex> Mnemonix.get(store, :a)
      3

      iex> store = Mnemonix.new
      iex> Mnemonix.bump!(store, :b, 2)
      :ok
      iex> Mnemonix.get(store, :b)
      2

      iex> store = Mnemonix.new(%{c: "foo"})
      iex> Mnemonix.bump!(store, :c, 2)
      ** (ArithmeticError) value at key :c is not an integer

      iex> store = Mnemonix.new
      iex> Mnemonix.bump!(store, :d, "foo")
      ** (ArithmeticError) value provided to operation is not an integer
  """
  @callback bump!(Mnemonix.store, Mnemonix.key, amount :: term)
    :: :ok | no_return
  @spec bump!(Mnemonix.store, Mnemonix.key, amount :: term)
    :: :ok | no_return
  def bump!(store, key, amount) do
    case GenServer.call(store, {:bump!, key, amount}) do
      :ok                  -> :ok
      {:raise, type, args} -> raise type, args
    end
  end

  @doc """
  Increments the value of the integer entry under `key` in `store` by `1`.

  If the `key` does not exist, it is set to `0` before performing the operation.

  If the value under `key` is not an integer, returns store unchanged.

  ## Examples

      iex> store = Mnemonix.new(%{a: 1})
      iex> Mnemonix.increment(store, :a)
      iex> Mnemonix.get(store, :a)
      2

      iex> store = Mnemonix.new
      iex> Mnemonix.increment(store, :b)
      iex> Mnemonix.get(store, :b)
      1

      iex> store = Mnemonix.new(%{c: "foo"})
      iex> Mnemonix.increment(store, :c)
      iex> Mnemonix.get(store, :c)
      "foo"
  """
  @callback increment(Mnemonix.store, Mnemonix.key)
    :: Mnemonix.store | no_return
  @spec increment(Mnemonix.store, Mnemonix.key)
    :: Mnemonix.store | no_return
  def increment(store, key) do
    case GenServer.call(store, {:increment, key}) do
      :ok                  -> store
      {:raise, type, args} -> raise type, args
    end
  end

  @doc """
  Increments the value of the integer entry under `key` in `store` by `amount`.

  If the `key` does not exist, it is set to `0` before performing the operation.

  If the `amount` or the value under `key` is not an integer, returns store unchanged.

  ## Examples

      iex> store = Mnemonix.new(%{a: 1})
      iex> Mnemonix.increment(store, :a, 2)
      iex> Mnemonix.get(store, :a)
      3

      iex> store = Mnemonix.new
      iex> Mnemonix.increment(store, :b, 2)
      iex> Mnemonix.get(store, :b)
      2

      iex> store = Mnemonix.new(%{c: "foo"})
      iex> Mnemonix.increment(store, :c, 2)
      iex> Mnemonix.get(store, :c)
      "foo"

      iex> store = Mnemonix.new
      iex> Mnemonix.increment(store, :d, "foo")
      iex> Mnemonix.get(store, :d)
      0
  """
  @callback increment(Mnemonix.store, Mnemonix.key, amount :: term)
    :: Mnemonix.store | no_return
  @spec increment(Mnemonix.store, Mnemonix.key, amount :: term)
    :: Mnemonix.store | no_return
  def increment(store, key, amount) do
    case GenServer.call(store, {:increment, key, amount}) do
      :ok                  -> store
      {:raise, type, args} -> raise type, args
    end
  end

  @doc """
  Decrements the value of the integer entry under `key` in `store` by `1`.

  If the `key` does not exist, it is set to `0` before performing the operation.

  If the value under `key` is not an integer, returns store unchanged.

  ## Examples

      iex> store = Mnemonix.new(%{a: 1})
      iex> Mnemonix.decrement(store, :a)
      iex> Mnemonix.get(store, :a)
      0

      iex> store = Mnemonix.new
      iex> Mnemonix.decrement(store, :b)
      iex> Mnemonix.get(store, :b)
      -1

      iex> store = Mnemonix.new(%{c: "foo"})
      iex> Mnemonix.decrement(store, :c)
      iex> Mnemonix.get(store, :c)
      "foo"
  """
  @callback decrement(Mnemonix.store, Mnemonix.key)
    :: Mnemonix.store | no_return
  @spec decrement(Mnemonix.store, Mnemonix.key)
    :: Mnemonix.store | no_return
  def decrement(store, key) do
    case GenServer.call(store, {:decrement, key}) do
      :ok                  -> store
      {:raise, type, args} -> raise type, args
    end
  end

  @doc """
  Decrements the value of the integer entry under `key` in `store` by `amount`.

  If the `key` does not exist, it is set to `0` before performing the operation.

  If `amount` or the value under `key` is not an integer, returns store unchanged.

  ## Examples

      iex> store = Mnemonix.new(%{a: 2})
      iex> Mnemonix.decrement(store, :a, 2)
      iex> Mnemonix.get(store, :a)
      0

      iex> store = Mnemonix.new
      iex> Mnemonix.decrement(store, :b, 2)
      iex> Mnemonix.get(store, :b)
      -2

      iex> store = Mnemonix.new(%{c: "foo"})
      iex> Mnemonix.decrement(store, :c, 2)
      iex> Mnemonix.get(store, :c)
      "foo"

      iex> store = Mnemonix.new
      iex> Mnemonix.decrement(store, :d, "foo")
      iex> Mnemonix.get(store, :d)
      0
  """
  @callback decrement(Mnemonix.store, Mnemonix.key, amount :: term)
    :: Mnemonix.store | no_return
  @spec decrement(Mnemonix.store, Mnemonix.key, amount :: term)
    :: Mnemonix.store | no_return
  def decrement(store, key, amount) do
    case GenServer.call(store, {:decrement, key, amount}) do
      :ok                  -> store
      {:raise, type, args} -> raise type, args
    end
  end

end
