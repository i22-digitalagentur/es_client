defmodule ESClient.RequestError do
  @moduledoc """
  An error that is returned or raised when the search API returned an error due
  to a bad request.
  """

  defexception [:reason]

  @type t :: %__MODULE__{reason: any}

  @impl true
  def message(%__MODULE__{} = error) do
    "Request error: #{error.reason}"
  end
end
