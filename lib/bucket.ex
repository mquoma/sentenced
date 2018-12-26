defmodule KV.Bucket do
  use Agent

  @doc """
  Bucket
  https://elixir-lang.org/getting-started/mix-otp/agent.html
  """

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end

  def get(bucket, key) do
    bucket
    |> Agent.get(fn b -> Map.get(b, key) end)
  end

  def put(bucket, key, value) do
    bucket
    |> Agent.update(fn b -> Map.put(b, key, value) end)
  end

  def delete(bucket, key) do
    bucket |> Agent.get_and_update(fn b -> Map.pop(b, key) end)
  end

  def index(bucket) do
    bucket |> Agent.get(fn b -> b |> Map.to_list() end)
  end
end
