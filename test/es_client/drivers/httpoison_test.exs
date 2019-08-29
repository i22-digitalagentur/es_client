defmodule ESClient.Drivers.HTTPoisonTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias ESClient.Drivers.HTTPoison, as: HTTPoisonDriver

  @base_url "https://jsonplaceholder.typicode.com"

  describe "request/5" do
    test "head request" do
      use_cassette "head_request" do
        assert {:ok, response} =
                 HTTPoisonDriver.request(
                   :head,
                   URI.parse("#{@base_url}/posts/1"),
                   "",
                   [],
                   []
                 )

        assert response.status_code == 200
        assert response.body == ""
      end
    end

    test "get request" do
      use_cassette "get_request" do
        assert {:ok, response} =
                 HTTPoisonDriver.request(
                   :get,
                   URI.parse("#{@base_url}/posts/1"),
                   "",
                   [],
                   []
                 )

        assert response.status_code == 200
        assert {:ok, %{"id" => 1}} = Jason.decode(response.body)
      end
    end

    test "post request" do
      use_cassette "post_request" do
        assert {:ok, response} =
                 HTTPoisonDriver.request(
                   :post,
                   URI.parse("#{@base_url}/posts"),
                   Jason.encode!(%{title: "foo", body: "bar"}),
                   [],
                   []
                 )

        assert response.status_code == 201
        assert {:ok, %{"id" => _}} = Jason.decode(response.body)
      end
    end

    test "put request" do
      use_cassette "put_request" do
        assert {:ok, response} =
                 HTTPoisonDriver.request(
                   :put,
                   URI.parse("#{@base_url}/posts/1"),
                   Jason.encode!(%{title: "foo", body: "bar"}),
                   [],
                   []
                 )

        assert response.status_code == 200
        assert {:ok, %{"id" => 1}} = Jason.decode(response.body)
      end
    end

    test "delete request" do
      use_cassette "delete_request" do
        assert {:ok, response} =
                 HTTPoisonDriver.request(
                   :delete,
                   URI.parse("#{@base_url}/posts/1"),
                   "",
                   [],
                   []
                 )

        assert response.status_code == 200
        assert Jason.decode(response.body) == {:ok, %{}}
      end
    end
  end
end
