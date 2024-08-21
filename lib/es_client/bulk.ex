defmodule ESClient.Bulk do
  @moduledoc """
  A struct that encapsulates multiple operations.
  """

  defstruct operations: []

  @type t :: %__MODULE__{operations: Enum.t()}

  @doc """
  Builds a new bulk collection.
  """
  @spec new(Enum.t()) :: t
  def new(operations \\ []) do
    %__MODULE__{operations: operations}
  end

  defimpl ESClient.Encodable do
    def encode(bulk, config) do
      data =
        bulk.operations
        |> Stream.flat_map(fn {type, meta, data} ->
          [%{type => meta}, data]
        end)
        |> Stream.map(&ESClient.Utils.json_library(config).encode!/1)
        |> Enum.join("\n")
        |> Kernel.<>("\n")

      {:ok, "application/x-ndjson", data}
    end
  end
end
