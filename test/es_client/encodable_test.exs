defmodule ESClient.EncodableTest do
  use ExUnit.Case, async: true

  alias ESClient.Bulk
  alias ESClient.Config
  alias ESClient.Encodable

  describe "encode/2" do
    @config %Config{}

    test "map" do
      data = %{"foo" => "bar"}

      assert Encodable.encode(data, @config) ==
               {:ok, "application/json", Jason.encode!(data)}
    end

    test "list" do
      data = [%{"foo" => "bar"}, %{"bar" => "baz"}]

      assert Encodable.encode(data, @config) ==
               {:ok, "application/json", Jason.encode!(data)}
    end

    test "bulk" do
      bulk = %Bulk{
        operations: [
          {:index, %{_id: 1}, %{name: "Foo"}},
          {:index, %{_id: 2}, %{name: "Bar"}}
        ]
      }

      assert Encodable.encode(bulk, @config) ==
               {:ok, "application/x-ndjson",
                [
                  %{"index" => %{"_id" => 1}},
                  %{"name" => "Foo"},
                  %{"index" => %{"_id" => 2}},
                  %{"name" => "Bar"}
                ]
                |> Enum.map(&Jason.encode!/1)
                |> Enum.join("\n")
                |> Kernel.<>("\n")}
    end
  end
end
