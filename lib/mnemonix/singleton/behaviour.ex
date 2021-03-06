defmodule Mnemonix.Singleton.Behaviour do
  @moduledoc false

  defmacro __using__(opts \\ []) do
    opts = Keyword.put(opts, :source, __CALLER__.module)

    quote location: :keep do
      @opts unquote(opts)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    opts = Module.get_attribute(env.module, :opts)
    types = Module.get_attribute(env.module, :type)
    callbacks = Module.get_attribute(env.module, :callback)

    quote location: :keep do
      defmodule alias!(Singleton) do
        @moduledoc false
        use Mnemonix.Behaviour, unquote(opts)

        unquote_splicing(
          for {:type, type, _module_info} <- types do
            quote(location: :keep, do: @type(unquote(type)))
          end
        )

        unquote_splicing(
          for {:callback, callback, _module_info} <- callbacks do
            quote(location: :keep, do: @callback(unquote(strip_first_callback_param(callback))))
          end
        )
      end
    end
  end

  def establish_singleton(module, opts) do
    singleton = Keyword.get(opts, :singleton, false)

    singleton = if singleton do
      Mnemonix.Singleton.Behaviour.determine_singleton(module, singleton)
    else
      singleton
    end

    opts = if singleton do
      Keyword.put(opts, :singleton, {module, singleton})
    else
      opts
    end

    {singleton, opts}
  end

  def determine_singleton(module, store) do
    case store do
      true -> Module.get_attribute(module, :singleton) || module
      name when is_atom(name) -> name
      {module, name} when is_atom(module) -> determine_singleton(module, name)
      _ -> false
    end
  end

  def strip_first_callback_param({:when, _, [node, names]}) do
    {:when, [], [strip_first_callback_param(node), names]}
  end

  def strip_first_callback_param({:::, _, [{name, _, args}, return]}) do
    {:::, [], [{name, [], tl(args)}, return]}
  end
end
