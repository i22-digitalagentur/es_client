defmodule ESClient.Batch do
  @moduledoc """
  A struct that encapsulates multiple operations.
  """

  defstruct operations: []

  @type t :: %__MODULE__{operations: Enum.t()}

  @doc """
  Builds a new batch.
  """
  @spec new(Enum.t()) :: t
  def new(operations \\ []) do
    %__MODULE__{operations: operations}
  end

  defimpl ESClient.Encodable do
    def encode(batch, config) do
      data =
        batch.operations
        |> Stream.flat_map(fn {type, meta, data} ->
          [%{type => meta}, data]
        end)
        |> Stream.map(&config.json_library.encode!/1)
        |> Enum.join("\n")
        |> Kernel.<>("\n")

      {:ok, "application/x-ndjson", data}
    end
  end
end
