defmodule Mnemonix.Store.Behaviours.Bump do
  @moduledoc false

  alias Mnemonix.Store
  alias Mnemonix.Features.Bump

  use Mnemonix.Behaviour

####
# DERIVABLE
##

  @callback bump(Store.t, Mnemonix.key, Bump.amount)
    :: Store.Server.instruction(Bump.result)
  @doc false
  @spec bump(Store.t, Mnemonix.key, Bump.amount)
    :: Store.Server.instruction(Bump.result)
  def bump(store, key, amount) do
    with {:ok, store, result} <- do_bump(store, :increment, key, amount) do
      case result do
        :ok ->
          {:ok, store}
        {:error, no_integer} ->
          {:ok, store, {:error, no_integer}}
      end
    end
  end

  @callback bump!(Store.t, Mnemonix.key, amount :: term)
    :: Store.Server.instruction
  @doc false
  @spec bump!(Store.t, Mnemonix.key, amount :: term)
    :: Store.Server.instruction
  def bump!(store, key, amount) do
    with {:ok, store, result} <- do_bump(store, :increment, key, amount) do
      case result do
        :ok ->
          {:ok, store}
        {:error, no_integer} ->
          {:raise, store, ArithmeticError, [message: msg_for(no_integer, store.impl.deserialize_key(store, key))]}
      end
    end
  end

  @callback increment(Store.t, Mnemonix.key)
    :: Store.Server.instruction
  @doc false
  @spec increment(Store.t, Mnemonix.key)
    :: Store.Server.instruction
  def increment(store, key), do: increment(store, key, 1)

  @callback increment(Store.t, Mnemonix.key, amount :: term)
    :: Store.Server.instruction
  @doc false
  @spec increment(Store.t, Mnemonix.key, amount :: term)
    :: Store.Server.instruction
  def increment(store, key, amount) do
    with {:ok, store} <- do_bump(store, :increment, key, amount) do
      {:ok, store}
    end
  end

  @callback decrement(Store.t, Mnemonix.key)
    :: Store.Server.instruction
  @doc false
  @spec decrement(Store.t, Mnemonix.key)
    :: Store.Server.instruction
  def decrement(store, key), do: decrement(store, key, 1)

  @callback decrement(Store.t, Mnemonix.key, amount :: term)
    :: Store.Server.instruction
  @doc false
  @spec decrement(Store.t, Mnemonix.key, amount :: term)
    :: Store.Server.instruction
  def decrement(store, key, amount) do
    with {:ok, store} <- do_bump(store, :decrement, key, amount) do
      {:ok, store}
    end
  end

  @doc false
  def msg_for(:amount, _key), do: "value provided to operation is not an integer"
  def msg_for(:value, key),   do: "value at key #{key |> Inspect.inspect(%Inspect.Opts{})} is not an integer"

  @doc false
  def do_bump(store, operation, key, amount) do
    with {:ok, store, current} <- store.impl.fetch(store, key) do
      case current do
        :error -> with {:ok, store} <- store.impl.put(store, key, store.impl.serialize_value(store, 0)) do
          do_bump(store, operation, key, amount)
        end
        {:ok, value} -> case do_bump_calculation(operation, store.impl.deserialize_value(store, value), amount) do
          {:ok, result} -> with {:ok, store} <- store.impl.put(store, key, store.impl.serialize_value(store, result)) do
            {:ok, store}
          end
          {:error, no_integer} -> {:ok, store, {:error, no_integer}}
        end
      end
    end
  end

  @doc false

  def do_bump_calculation(_operation, _value, amount) when not is_integer(amount), do: {:error, :amount}
  def do_bump_calculation(_operation, value, _amount) when not is_integer(value),  do: {:error, :value}

  def do_bump_calculation(:increment, value, amount), do: {:ok, value + amount}
  def do_bump_calculation(:decrement, value, amount), do: {:ok, value - amount}

end
