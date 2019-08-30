defmodule TestClientTest do
  use ExUnit.Case, async: true

  import Mox

  alias ESClient.Codec
  alias ESClient.Config
  alias ESClient.ConfigRegistry
  alias ESClient.Drivers.Mock, as: MockDriver
  alias ESClient.Response
  alias ESClient.Utils

  setup do
    start_supervised!(ConfigRegistry)
    :ok
  end

  @path "my-index/_search"

  describe "__config__/0" do
    test "get config" do
      assert TestClient.__config__() ==
               Config.new(Application.get_env(:es_client, TestClient, []))
    end
  end

  describe "request/4" do
    test "success" do
      config = TestClient.__config__()
      url = Utils.build_url(config, @path)
      opts = [recv_timeout: config.timeout]

      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :get, ^url, ^req_body, [], ^opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(config, resp_data)
         }}
      end)

      assert TestClient.request(:get, @path, req_data) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: resp_data,
                  status_code: 200
                }}
    end
  end

  describe "request!/4" do
    test "success" do
      config = TestClient.__config__()
      url = Utils.build_url(config, @path)
      opts = [recv_timeout: config.timeout]

      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :get, ^url, ^req_body, [], ^opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(config, resp_data)
         }}
      end)

      assert TestClient.request!(:get, @path, req_data) ==
               %Response{
                 content_type: "application/json",
                 data: resp_data,
                 status_code: 200
               }
    end
  end
end
