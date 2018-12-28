defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(KV.Registry)
    %{registry: registry} |> IO.inspect(label: "reg--")
  end

  test "removes bucket if crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    # #
    # IO.inspect(bucket, label: "buuuuuuuuuck")
    #
    # Agent.stop(bucket, :shutdown)
    # assert KV.Registry.lookup(registry, "shopping") == :error
    assert true == false
  end
end
