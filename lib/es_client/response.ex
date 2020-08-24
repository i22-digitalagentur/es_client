defmodule ESClient.Response do
  @moduledoc """
  A struct containing the response data for an Elasticsearch request.
  """

  defstruct [:content_type, :data, :status_code]

  @type t :: %__MODULE__{
          content_type: String.t(),
          data: any,
          status_code: integer
        }
end
