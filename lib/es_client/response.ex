defmodule ESClient.Response do
  @moduledoc """
  A struct containing the response data for an Elasticsearch request.
  """

  defstruct [:content_type, :data, :status_code]

  @type t :: %__MODULE__{
          content_type: String.t(),
          data: binary | %{optional(atom) => any},
          status_code: integer
        }

  @doc """
  Gets the hits from the response.
  """
  @spec hits(t) :: [%{optional(atom) => any}]
  def hits(response)

  def hits(%__MODULE__{data: data} = response) when is_map(data) do
    response.data
    |> get_in([:hits, :hits])
    |> List.wrap()
  end

  def hits(%__MODULE__{}), do: []
end
