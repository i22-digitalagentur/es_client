defmodule ESClient.CodecTest do
  use ExUnit.Case, async: true

  import Mox

  alias ESClient.Codec
  alias ESClient.CodecError
  alias ESClient.Config

  setup :verify_on_exit!

  @config %Config{json_library: MockJSONCodec}

  describe "decode/3" do
    test "get nil when data nil" do
      assert Codec.decode(@config, "application/json", nil) == {:ok, nil}
      assert Codec.decode(@config, "text/plain", nil) == {:ok, nil}
    end

    test "get nil when data is empty string" do
      assert Codec.decode(@config, "application/json", "") == {:ok, nil}
      assert Codec.decode(@config, "text/plain", "") == {:ok, nil}
    end

    test "decode data when data is string and content type is application/json" do
      encoded_data = "this is my encoded data"
      decoded_data = %{this: %{is: %{my: ["decoded", "data"]}}}

      expect(MockJSONCodec, :decode, fn ^encoded_data, [keys: :atoms] ->
        {:ok, decoded_data}
      end)

      assert Codec.decode(@config, "application/json", encoded_data) ==
               {:ok, decoded_data}
    end

    test "return data when data is string and content type not application/json" do
      str = "this is a string"

      assert Codec.decode(@config, "text/plain", str) == {:ok, str}
    end

    test "decode error" do
      data = "this is my encoded data"
      error = %{message: "Something went wrong"}

      expect(MockJSONCodec, :decode, fn ^data, [keys: :atoms] ->
        {:error, error}
      end)

      assert Codec.decode(@config, "application/json", data) ==
               {:error,
                %CodecError{
                  operation: :decode,
                  data: data,
                  original_error: error
                }}
    end

    test "unexpected arg error" do
      Enum.each([1234, 1234.5, :invalid], fn value ->
        error = %CodecError{operation: :decode, data: value}

        assert Codec.decode(@config, "application/json", value) ==
                 {:error, error}

        assert Codec.decode(@config, "text/plain", value) == {:error, error}
      end)
    end
  end

  describe "decode!/3" do
    test "get nil when data nil" do
      assert Codec.decode!(@config, "application/json", nil) == nil
      assert Codec.decode!(@config, "text/plain", nil) == nil
    end

    test "get nil when data is empty string" do
      assert Codec.decode!(@config, "application/json", "") == nil
      assert Codec.decode!(@config, "text/plain", "") == nil
    end

    test "decode data when data is string and content type is application/json" do
      encoded_data = "this is my encoded data"
      decoded_data = %{this: %{is: %{my: ["decoded", "data"]}}}

      expect(MockJSONCodec, :decode, fn ^encoded_data, [keys: :atoms] ->
        {:ok, decoded_data}
      end)

      assert Codec.decode!(@config, "application/json", encoded_data) ==
               decoded_data
    end

    test "return data when data is string and content type not application/json" do
      str = "this is a string"

      assert Codec.decode!(@config, "text/plain", str) == str
    end

    test "decode error" do
      data = "this is my encoded data"
      error = %{message: "Something went wrong"}

      expect(MockJSONCodec, :decode, fn ^data, [keys: :atoms] ->
        {:error, error}
      end)

      assert_raise CodecError, "Unable to decode data", fn ->
        Codec.decode!(@config, "application/json", data)
      end
    end

    test "unexpected arg error" do
      Enum.each([1234, 1234.5, :invalid], fn value ->
        error = %CodecError{operation: :decode, data: value}

        assert Codec.decode(@config, "application/json", value) ==
                 {:error, error}

        assert_raise CodecError, "Unable to decode data", fn ->
          Codec.decode!(@config, "text/plain", value)
        end
      end)
    end
  end

  describe "encode/3" do
    test "get empty string when data nil" do
      assert Codec.encode(@config, nil) == {:ok, ""}
    end

    test "return data when data is string" do
      data = "this is my encoded data"

      assert Codec.encode(@config, data) == {:ok, data}
    end

    test "encode data when data is map" do
      decoded_data = %{this: %{is: %{my: ["decoded", "data"]}}}
      encoded_data = "this is my encoded data"

      expect(MockJSONCodec, :encode, fn ^decoded_data ->
        {:ok, encoded_data}
      end)

      assert Codec.encode(@config, decoded_data) == {:ok, encoded_data}
    end

    test "encode data when data is list" do
      decoded_data = [%{this: %{is: %{my: ["decoded", "data"]}}}]
      encoded_data = "this is my encoded data"

      expect(MockJSONCodec, :encode, fn ^decoded_data ->
        {:ok, encoded_data}
      end)

      assert Codec.encode(@config, decoded_data) == {:ok, encoded_data}
    end

    test "encode error" do
      data = %{this: %{is: %{my: ["decoded", "data"]}}}
      error = %{message: "Something went wrong"}

      expect(MockJSONCodec, :encode, fn ^data ->
        {:error, error}
      end)

      assert Codec.encode(@config, data) ==
               {:error,
                %CodecError{
                  operation: :encode,
                  data: data,
                  original_error: error
                }}
    end
  end

  describe "encode!/3" do
    test "get empty string when data nil" do
      assert Codec.encode!(@config, nil) == ""
    end

    test "return data when data is string" do
      data = "this is my encoded data"

      assert Codec.encode!(@config, data) == data
    end

    test "encode data when data is map" do
      decoded_data = %{this: %{is: %{my: ["decoded", "data"]}}}
      encoded_data = "this is my encoded data"

      expect(MockJSONCodec, :encode, fn ^decoded_data ->
        {:ok, encoded_data}
      end)

      assert Codec.encode!(@config, decoded_data) == encoded_data
    end

    test "encode data when data is list" do
      decoded_data = [%{this: %{is: %{my: ["decoded", "data"]}}}]
      encoded_data = "this is my encoded data"

      expect(MockJSONCodec, :encode, fn ^decoded_data ->
        {:ok, encoded_data}
      end)

      assert Codec.encode!(@config, decoded_data) == encoded_data
    end

    test "encode error" do
      data = %{this: %{is: %{my: ["decoded", "data"]}}}
      error = %{message: "Something went wrong"}

      expect(MockJSONCodec, :encode, fn ^data ->
        {:error, error}
      end)

      assert_raise CodecError, "Unable to encode data", fn ->
        Codec.encode!(@config, data)
      end
    end
  end
end
