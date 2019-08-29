defmodule ESClient.CodecError do
  @moduledoc """
  An error that is returned or raised when decoding of response data or encoding
  of request data fails.
  """

  @type t :: %__MODULE__{
          data: any,
          operation: :decode | :encode,
          original_error: nil | any
        }

  defexception [:operation, :data, :original_error]

  @impl true
  def message(error) do
    "Unable to #{error.operation} data"
  end
end
