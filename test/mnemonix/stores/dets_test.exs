defmodule Mnemonix.Stores.DETS.Test do
  use Mnemonix.Test.Case, async: true

  @moduletag :dets

  setup do
    on_exit fn ->
      :dets.close(Mnemonix.Stores.DETS.Table)
      File.rm_rf("Elixir.Mnemonix.Stores.DETS.Table")
      :ok
    end
  end

  doctest Mnemonix.Stores.DETS

end
