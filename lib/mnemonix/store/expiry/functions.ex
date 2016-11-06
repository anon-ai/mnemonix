defmodule Mnemonix.Store.Expiry.Functions do
  @moduledoc false

  @doc false
  defmacro __using__(_) do
    quote location: :keep do

      alias Mnemonix.Store.Expiry

      @doc false
      def setup_expiry(store = %Mnemonix.Store{opts: opts}) do
        with {:ok, engine} <- Expiry.Engine.start_link(opts) do
          {:ok, %{ store | expiry: engine }}
        end
      end
      defoverridable setup_expiry: 1

      @doc false
      def expires(store, key, ttl) do
        with :ok <- Expiry.Engine.expires(store, key, ttl) do
          {:ok, store}
        end
      end
      defoverridable expires: 3

      @doc false
      def persist(store, key) do
        with :ok <- Expiry.Engine.persist(store, key) do
          {:ok, store}
        end
      end
      defoverridable persist: 2

    end
  end

end
