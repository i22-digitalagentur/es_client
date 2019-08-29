defmodule ESClient.CodecErrorTest do
  use ExUnit.Case, async: true

  alias ESClient.CodecError

  @error %CodecError{operation: :decode}

  test "raiseable" do
    assert_raise CodecError, fn ->
      raise @error
    end
  end

  describe "message/1" do
    test "decode error" do
      assert CodecError.message(@error) == "Unable to decode data"
    end

    test "encode error" do
      error = %{@error | operation: :encode}

      assert CodecError.message(error) == "Unable to encode data"
    end
  end
end
