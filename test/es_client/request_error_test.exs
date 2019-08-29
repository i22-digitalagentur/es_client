defmodule RubberBand.RequestErrorTest do
  use ExUnit.Case, async: true

  alias ESClient.RequestError

  @error %RequestError{reason: :timeout}

  test "raiseable" do
    assert_raise RequestError, fn ->
      raise @error
    end
  end

  describe "message/1" do
    test "get message" do
      assert RequestError.message(@error) == "Request error: #{@error.reason}"
    end
  end
end
