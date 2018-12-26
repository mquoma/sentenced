defmodule KVTest do
  use ExUnit.Case
  doctest KV

  test "passes" do
    assert KV.hello() == :world
  end

  test "fails" do
    assert KV.hello() != :oops
  end
end
