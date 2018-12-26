defmodule SmartCatalog do
  @moduledoc """
  Documentation for SmartCatalog.
  """

  @doc """
  Query.

  ## Examples

      iex> SmartCatalog.query()
      %Tds.Result{
        columns: [],
        num_rows: 0,
        rows: []
      }

  """
  defp query(sql, conn) do
    results = Tds.query!(conn, sql, [])
  end

  defp conn() do
    {:ok, pid} =
      Application.get_env(:kv, :tds_dev)
      |> Tds.start_link()

    pid
  end

  defp query(sql, params) do
    {:ok, pid} =
      Application.get_env(:kv, :tds_dev)
      |> Tds.start_link()

    results = Tds.query!(pid, sql, params)

  end

  def query_by_name(conn, name) do
    "SELECT DISTINCT ID AS uuid, CAST(ID as nvarchar(255)) AS id, Name AS name, CAST(Created AS nvarchar(255)) AS created FROM dbo.items WHERE Name LIKE '%#{
      name
    }%'"
    |> query(conn) |> to_map()
  end

  def query_by_uuid(conn, uuid) do
    "SELECT DISTINCT ID AS uuid, CAST(ID as nvarchar(255)) AS id, CAST(ParentId as nvarchar(255)) AS parent_id, name, CAST(Created AS nvarchar(255)) AS created FROM dbo.items WHERE ID LIKE '#{
      uuid
    }'"
    |> query(conn)

  end

  def get_children(conn, uuid) do
    children =
      "SELECT DISTINCT ID AS uuid, CAST(ID as nvarchar(255)) AS id, CAST(ParentId as nvarchar(255)) AS parent_id, name, CAST(Created AS nvarchar(255)) AS created FROM dbo.items WHERE ParentId = '#{
        uuid
      }'"
      |> query(conn) |> to_map()

      case children do
        %{} ->
          %{}
        [] ->
          []
        children ->
          children |> Enum.map(fn a -> a |> Map.put(:children, get_children(conn, a.id)) end)

      end

  end

  def get_hierarchy(uuid) do

    conn = conn()
    children = get_children(conn, uuid)

  end

  def get_all() do
    conn = conn()
    "SELECT DISTINCT ID AS uuid, CAST(ID as nvarchar(255)) AS id, Name AS name, CAST(Created AS nvarchar(255)) AS created FROM dbo.items"
      |> query(conn)
      |> to_map()
  end

  def query_field_by_itemid(conn, uuid) do
    "SELECT DISTINCT ID AS uuid, CAST(ID as nvarchar(255)) AS id, Value AS value, CAST (Created AS nvarchar(255)) AS created FROM dbo.Fields WHERE ItemID = '#{
      uuid
    }'"
    |> query(conn)
  end

  def update_name_by_uuid(name, uuid, itemid) do
    params = [
      %Tds.Parameter{name: "@name", type: :string, value: name},
      %Tds.Parameter{name: "@uuid", type: :string, value: uuid},
      %Tds.Parameter{name: "@itemid", type: :string, value: itemid}
    ]

    "UPDATE dbo.VersionedFields SET Value = @name WHERE ID = @uuid AND ItemId = @itemid"
    |> query(params)
  end

  def insert_field(name, itemid, fieldid, version, language) do
    params = [
      %Tds.Parameter{name: "@name", type: :string, value: name},
      %Tds.Parameter{name: "@itemid", type: :string, value: itemid},
      %Tds.Parameter{name: "@fieldid", type: :string, value: fieldid},
      %Tds.Parameter{name: "@version", type: :integer, value: version},
      %Tds.Parameter{name: "@language", type: :string, value: language}
    ]

    "INSERT INTO dbo.VersionedFields (ItemId, Value, FieldId, Version, Language, Created, Updated) VALUES (@itemid, @name, @FieldId, @version, @language, GetDate(), GetDate())"
    |> query(params)
  end

  defp to_map(results) do

    %{rows: rows, columns: cols} = results

     rows |> Enum.map(fn a -> Enum.zip(cols |> Enum.map(&String.to_atom/1), a) |> Enum.into(%{}) end)
  end
end
