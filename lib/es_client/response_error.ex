defmodule ESClient.ResponseError do
  @moduledoc """
  An error that is returned or raised when the search endpoint returns error
  details.
  """

  defexception [
    :col,
    :data,
    :line,
    :reason,
    :status_code,
    :type
  ]

  @type t :: %__MODULE__{
          col: nil | non_neg_integer,
          data: nil | %{optional(atom) => any},
          line: nil | non_neg_integer,
          reason: any,
          status_code: integer,
          type: nil | String.t()
        }
  @impl true
  def message(%__MODULE__{} = error) do
    "Response error: #{error.reason} (#{error.type})"
  end
end
