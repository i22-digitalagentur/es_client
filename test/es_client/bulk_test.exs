defmodule ESClient.BulkTest do
  use ExUnit.Case, async: true

  alias ESClient.Bulk

  describe "new/0" do
    test "build new bulk struct" do
      assert Bulk.new() == %Bulk{operations: []}
    end
  end

  describe "new/1" do
    test "build new bulk struct with operations" do
      operations = [
        {:index, %{_id: 1}, %{name: "Foo"}},
        {:index, %{_id: 2}, %{name: "Bar"}}
      ]

      assert Bulk.new(operations) == %Bulk{operations: operations}
    end
  end
end
