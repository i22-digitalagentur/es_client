defmodule ESClient.ConfigTest do
  use ExUnit.Case, async: true

  alias ESClient.Config

  describe "new/1" do
    test "build with config" do
      config = Config.new([])

      assert Config.new(config) == config
    end

    test "build with empty list" do
      config = Config.new([])

      assert config == %Config{
               base_url: "http://localhost:9200",
               driver: ESClient.Drivers.HTTPoison,
               json_codec: Jason,
               timeout: 15_000
             }

      assert config == Config.new(%{})
    end

    test "build with list" do
      base_url = "http://elasticsearch/path"
      driver = ESClient.Drivers.Mock
      json_codec = MockJSONCodec
      timeout = :infinity

      assert Config.new(
               base_url: base_url,
               driver: driver,
               json_codec: json_codec,
               timeout: timeout
             ) == %Config{
               base_url: base_url,
               driver: driver,
               json_codec: json_codec,
               timeout: timeout
             }
    end

    test "build with map" do
      base_url = "http://elasticsearch/path"
      driver = ESClient.Drivers.Mock
      json_codec = MockJSONCodec
      timeout = :infinity

      assert Config.new(%{
               base_url: base_url,
               driver: driver,
               json_codec: json_codec,
               timeout: timeout
             }) == %Config{
               base_url: base_url,
               driver: driver,
               json_codec: json_codec,
               timeout: timeout
             }
    end
  end
end
