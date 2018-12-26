defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
    bucket |> KV.Bucket.put("milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "gets a value and updates it", %{bucket: bucket} do
    assert 1 == 0
  end
end
