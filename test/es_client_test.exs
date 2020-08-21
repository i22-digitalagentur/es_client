defmodule ESClientTest do
  use ExUnit.Case, async: true

  import Mox

  alias ESClient.Codec
  alias ESClient.CodecError
  alias ESClient.Config
  alias ESClient.Drivers.Mock, as: MockDriver
  alias ESClient.RequestError
  alias ESClient.Response
  alias ESClient.ResponseError
  alias ESClient.Utils

  @config %Config{driver: MockDriver, json_keys: :atoms, timeout: 5000}
  @opts [recv_timeout: 5000]
  @path "my-index/_search"
  @url Utils.build_url(@config, @path)

  setup :verify_on_exit!

  describe "use" do
    test "success" do
      defmodule SuccessTestClient do
        use ESClient, otp_app: :es_client
      end

      assert ESClient in SuccessTestClient.__info__(:attributes)[:behaviour]
    end

    test "raise when no :otp_app specified" do
      assert_raise KeyError, "key :otp_app not found in: []", fn ->
        defmodule ErrorTestClient do
          use ESClient
        end
      end
    end
  end

  describe "request/3" do
    test "success" do
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.request(@config, :get, @path) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: resp_data,
                  status_code: 200
                }}
    end

    test "decode error" do
      resp_body = "{{"

      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert {:error, %CodecError{data: resp_body, operation: :decode}} =
               ESClient.request(@config, :put, @path)
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :head, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.request(@config, :head, @path) ==
               {:error, %RequestError{reason: reason}}
    end

    test "invalid content type error" do
      reason = "Content-Type header [application/octet-stream] is not supported"

      resp_data = %{
        error: reason
      }

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 400,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.request(@config, :delete, @path) ==
               {:error,
                %ResponseError{
                  col: nil,
                  data: resp_data,
                  line: nil,
                  reason: reason,
                  status_code: 400,
                  type: nil
                }}
    end

    test "invalid content type error with string JSON keys" do
      config = %{@config | json_keys: :strings}
      reason = "Content-Type header [application/octet-stream] is not supported"

      resp_data = %{
        "error" => reason
      }

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 400,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(config, resp_data)
         }}
      end)

      assert ESClient.request(config, :delete, @path) ==
               {:error,
                %ResponseError{
                  col: nil,
                  data: resp_data,
                  line: nil,
                  reason: reason,
                  status_code: 400,
                  type: nil
                }}
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.request(@config, :delete, @path) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end

    test "response error with string JSON keys" do
      config = %{@config | json_keys: :strings}

      resp_data = %{
        "error" => %{
          "col" => 1,
          "line" => 3,
          "reason" => "Something went wrong",
          "type" => "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(config, resp_data)
         }}
      end)

      assert ESClient.request(config, :delete, @path) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "request!/3" do
    test "success" do
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.request!(@config, :get, @path) ==
               %Response{
                 content_type: "application/json",
                 data: resp_data,
                 status_code: 200
               }
    end

    test "decode error" do
      resp_body = "{{"

      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert_raise CodecError, "Unable to decode data", fn ->
        ESClient.request!(@config, :put, @path)
      end
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :post, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.request!(@config, :post, @path)
      end
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.request!(@config, :delete, @path)
                   end
    end
  end

  describe "request/4" do
    test "success" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.request(@config, :post, @path, req_data) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: resp_data,
                  status_code: 200
                }}
    end

    test "encode error" do
      req_data = {:some, :undecodable, "data"}

      assert {:error, %CodecError{data: req_data, operation: :encode}} =
               ESClient.request(@config, :post, @path, req_data)
    end

    test "decode error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_body = "{{"

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert {:error, %CodecError{data: resp_body, operation: :decode}} =
               ESClient.request(@config, :put, @path, req_data)
    end

    test "request error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.request(@config, :put, @path, req_data) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :delete,
                                      @url,
                                      ^req_body,
                                      _headers,
                                      @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.request(@config, :delete, @path, req_data) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "request!/4" do
    test "success" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.request!(@config, :post, @path, req_data) ==
               %Response{
                 content_type: "application/json",
                 data: resp_data,
                 status_code: 200
               }
    end

    test "encode error" do
      req_data = {:some, :undecodable, "data"}

      assert_raise CodecError, "Unable to encode data", fn ->
        ESClient.request!(@config, :post, @path, req_data)
      end
    end

    test "decode error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_body = "{{"

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert_raise CodecError, "Unable to decode data", fn ->
        ESClient.request!(@config, :put, @path, req_data)
      end
    end

    test "request error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:error, %{reason: "Something went wrong"}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.request!(@config, :put, @path, req_data)
      end
    end

    test "response error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :delete,
                                      @url,
                                      ^req_body,
                                      _headers,
                                      @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.request!(@config, :delete, @path, req_data)
                   end
    end
  end

  describe "head/2" do
    test "success" do
      expect(MockDriver, :request, fn :head, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.head(@config, @path) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: nil,
                  status_code: 200
                }}
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :head, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.head(@config, @path) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :head, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.head(@config, @path) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "head!/2" do
    test "success" do
      expect(MockDriver, :request, fn :head, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.head!(@config, @path) == %Response{
               content_type: "application/json",
               data: nil,
               status_code: 200
             }
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :head, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.head!(@config, @path)
      end
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :head, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.head!(@config, @path)
                   end
    end
  end

  describe "get/2" do
    test "success" do
      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.get(@config, @path) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: nil,
                  status_code: 200
                }}
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.get(@config, @path) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.get(@config, @path) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "get!/2" do
    test "success" do
      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.get!(@config, @path) == %Response{
               content_type: "application/json",
               data: nil,
               status_code: 200
             }
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.get!(@config, @path)
      end
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :get, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.get!(@config, @path)
                   end
    end
  end

  describe "post/2" do
    test "success" do
      expect(MockDriver, :request, fn :post, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.post(@config, @path) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: nil,
                  status_code: 200
                }}
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :post, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.post(@config, @path) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :post, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.post(@config, @path) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "post!/2" do
    test "success" do
      expect(MockDriver, :request, fn :post, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.post!(@config, @path) == %Response{
               content_type: "application/json",
               data: nil,
               status_code: 200
             }
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :post, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.post!(@config, @path)
      end
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :post, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.post!(@config, @path)
                   end
    end
  end

  describe "post/3" do
    test "success" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.post(@config, @path, req_data) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: resp_data,
                  status_code: 200
                }}
    end

    test "encode error" do
      req_data = {:some, :undecodable, "data"}

      assert {:error, %CodecError{data: req_data, operation: :encode}} =
               ESClient.post(@config, @path, req_data)
    end

    test "decode error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_body = "{{"

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert {:error, %CodecError{data: resp_body, operation: :decode}} =
               ESClient.post(@config, @path, req_data)
    end

    test "request error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.post(@config, @path, req_data) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.post(@config, @path, req_data) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "post!/3" do
    test "success" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.post!(@config, @path, req_data) ==
               %Response{
                 content_type: "application/json",
                 data: resp_data,
                 status_code: 200
               }
    end

    test "encode error" do
      req_data = {:some, :undecodable, "data"}

      assert_raise CodecError, "Unable to encode data", fn ->
        ESClient.post!(@config, @path, req_data)
      end
    end

    test "decode error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_body = "{{"

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert_raise CodecError, "Unable to decode data", fn ->
        ESClient.post!(@config, @path, req_data)
      end
    end

    test "request error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:error, %{reason: "Something went wrong"}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.post!(@config, @path, req_data)
      end
    end

    test "response error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :post, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.post!(@config, @path, req_data)
                   end
    end
  end

  describe "put/2" do
    test "success" do
      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.put(@config, @path) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: nil,
                  status_code: 200
                }}
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.put(@config, @path) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.put(@config, @path) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "put!/2" do
    test "success" do
      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.put!(@config, @path) == %Response{
               content_type: "application/json",
               data: nil,
               status_code: 200
             }
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.put!(@config, @path)
      end
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :put, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.put!(@config, @path)
                   end
    end
  end

  describe "put/3" do
    test "success" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.put(@config, @path, req_data) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: resp_data,
                  status_code: 200
                }}
    end

    test "encode error" do
      req_data = {:some, :undecodable, "data"}

      assert {:error, %CodecError{data: req_data, operation: :encode}} =
               ESClient.put(@config, @path, req_data)
    end

    test "decode error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_body = "{{"

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert {:error, %CodecError{data: resp_body, operation: :decode}} =
               ESClient.put(@config, @path, req_data)
    end

    test "request error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.put(@config, @path, req_data) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.put(@config, @path, req_data) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "put!/3" do
    test "success" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_data = %{my: %{resp: "data"}}

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.put!(@config, @path, req_data) ==
               %Response{
                 content_type: "application/json",
                 data: resp_data,
                 status_code: 200
               }
    end

    test "encode error" do
      req_data = {:some, :undecodable, "data"}

      assert_raise CodecError, "Unable to encode data", fn ->
        ESClient.put!(@config, @path, req_data)
      end
    end

    test "decode error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)
      resp_body = "{{"

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: resp_body
         }}
      end)

      assert_raise CodecError, "Unable to decode data", fn ->
        ESClient.put!(@config, @path, req_data)
      end
    end

    test "request error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:error, %{reason: "Something went wrong"}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.put!(@config, @path, req_data)
      end
    end

    test "response error" do
      req_data = %{my: %{req: "data"}}
      req_body = Codec.encode!(@config, req_data)

      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :put, @url, ^req_body, _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.put!(@config, @path, req_data)
                   end
    end
  end

  describe "delete/2" do
    test "success" do
      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.delete(@config, @path) ==
               {:ok,
                %Response{
                  content_type: "application/json",
                  data: nil,
                  status_code: 200
                }}
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert ESClient.delete(@config, @path) ==
               {:error, %RequestError{reason: reason}}
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert ESClient.delete(@config, @path) ==
               {:error,
                %ResponseError{
                  col: 1,
                  data: resp_data,
                  line: 3,
                  reason: "Something went wrong",
                  status_code: 200,
                  type: "unexpected_error"
                }}
    end
  end

  describe "delete!/2" do
    test "success" do
      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: ""
         }}
      end)

      assert ESClient.delete!(@config, @path) == %Response{
               content_type: "application/json",
               data: nil,
               status_code: 200
             }
    end

    test "request error" do
      reason = "Something went wrong"

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:error, %{reason: reason}}
      end)

      assert_raise RequestError, "Request error: Something went wrong", fn ->
        ESClient.delete!(@config, @path)
      end
    end

    test "response error" do
      resp_data = %{
        error: %{
          col: 1,
          line: 3,
          reason: "Something went wrong",
          type: "unexpected_error"
        }
      }

      expect(MockDriver, :request, fn :delete, @url, "", _headers, @opts ->
        {:ok,
         %{
           status_code: 200,
           headers: [{"content-type", "application/json; charset=utf-8"}],
           body: Codec.encode!(@config, resp_data)
         }}
      end)

      assert_raise ResponseError,
                   "Response error: Something went wrong (unexpected_error)",
                   fn ->
                     ESClient.delete!(@config, @path)
                   end
    end
  end
end
