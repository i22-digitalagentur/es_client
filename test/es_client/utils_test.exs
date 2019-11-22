defmodule ESClient.UtilsTest do
  use ExUnit.Case, async: false

  alias ESClient.Config
  alias ESClient.Utils

  describe "build_url/1" do
    test "get URL when path nil" do
      base_url = "http://localhost:9200/root"
      config = %Config{base_url: base_url}

      assert Utils.build_url(config, nil) == URI.parse(base_url)
    end

    test "get URL when path blank" do
      base_url = "http://localhost:9200/root"
      config = %Config{base_url: base_url}

      assert Utils.build_url(config, "") == URI.parse(base_url)
    end

    test "get URL when path is slash" do
      base_url = "http://localhost:9200/root"
      config = %Config{base_url: base_url}

      assert Utils.build_url(config, "/") == URI.parse(base_url)
    end

    test "get URL when base URL has trailing slash and path has leading slash" do
      config = %Config{base_url: "http://localhost:9200/root/"}

      assert Utils.build_url(config, "/my-path") ==
               URI.parse("http://localhost:9200/root/my-path")
    end

    test "get URL when base URL has trailing slash and path has no leading slash" do
      config = %Config{base_url: "http://localhost:9200/root/"}

      assert Utils.build_url(config, "my-path") ==
               URI.parse("http://localhost:9200/root/my-path")
    end

    test "get URL when base URL has no trailing slash and path has leading slash" do
      config = %Config{base_url: "http://localhost:9200/root"}

      assert Utils.build_url(config, "/my-path") ==
               URI.parse("http://localhost:9200/root/my-path")
    end

    test "get URL when base URL has no trailing slash and path has no leading slash" do
      config = %Config{base_url: "http://localhost:9200/root"}

      assert Utils.build_url(config, "my-path") ==
               URI.parse("http://localhost:9200/root/my-path")
    end

    test "get URL with path segments" do
      config = %Config{base_url: "http://localhost:9200/root"}

      assert Utils.build_url(config, ["my-path", "my-nested-path"]) ==
               URI.parse("http://localhost:9200/root/my-path/my-nested-path")
    end

    test "get URL with path and query" do
      config = %Config{base_url: "http://localhost:9200/root"}

      assert Utils.build_url(
               config,
               {"my-path/my-nested-path",
                query1: "query content", query2: "value"}
             ) ==
               URI.parse(
                 "http://localhost:9200/root/my-path/my-nested-path" <>
                   "?query1=query+content&query2=value"
               )
    end

    test "get URL with path segments and keyword query" do
      config = %Config{base_url: "http://localhost:9200/root"}

      assert Utils.build_url(
               config,
               {["my-path", "my-nested-path"],
                query1: "query content", query2: "value"}
             ) ==
               URI.parse(
                 "http://localhost:9200/root/my-path/my-nested-path" <>
                   "?query1=query+content&query2=value"
               )
    end

    test "get URL with path segments and map query" do
      config = %Config{base_url: "http://localhost:9200/root"}

      assert Utils.build_url(
               config,
               {["my-path", "my-nested-path"],
                %{query1: "query content", query2: "value"}}
             ) ==
               URI.parse(
                 "http://localhost:9200/root/my-path/my-nested-path" <>
                   "?query1=query+content&query2=value"
               )
    end

    test "get URL when base URL has no path segments" do
      config = %Config{base_url: "http://localhost:9200"}

      assert Utils.build_url(config, "my-index/_search") ==
               URI.parse("http://localhost:9200/my-index/_search")
    end

    test "raise when base URL nil" do
      assert_raise ArgumentError, "Missing base URL", fn ->
        Utils.build_url(%Config{base_url: nil}, "another-path")
      end
    end
  end
end
