defmodule ESClient.ResponseTest do
  use ExUnit.Case, async: true

  alias ESClient.Response

  describe "hits/1" do
    test "get hits from data if hits present" do
      hits = [%{fake: "hit 1"}, %{fake: "hit 2"}]
      resp = %Response{data: %{hits: %{hits: hits}}}

      assert Response.hits(resp) == hits
    end

    test "get empty list if hits missing" do
      assert Response.hits(%Response{}) == []
    end

    test "get empty list if data is no map" do
      resp = %Response{data: "this is a string"}

      assert Response.hits(resp) == []
    end
  end
end
