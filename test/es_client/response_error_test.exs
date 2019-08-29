defmodule ESClient.ResponseErrorTest do
  use ExUnit.Case, async: true

  alias ESClient.ResponseError

  @error %ResponseError{
    col: 4,
    data: %{my: %{error: "payload"}},
    line: 5,
    reason: "Something went wrong",
    status_code: 500,
    type: "something_went_wrong"
  }

  test "raiseable" do
    assert_raise ResponseError, fn ->
      raise @error
    end
  end

  describe "message/1" do
    test "get message" do
      assert ResponseError.message(@error) ==
               "Response error: #{@error.reason} (#{@error.type})"
    end
  end
end
