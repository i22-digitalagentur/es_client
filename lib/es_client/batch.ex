defmodule ESClient.Batch do
  @moduledoc """
  A struct that encapsulates multiple operations.
  """

  defstruct operations: []

  @type payload :: Keyword.t() | %{optional(atom | String.t()) => any}

  @type t :: %__MODULE__{operations: Enum.t()}

  @doc """
  Builds a new batch.
  """
  @spec new(Enum.t()) :: t
  def new(operations \\ []) do
    %__MODULE__{operations: operations}
  end

  @doc """
  Adds an operation to the batch.
  """
  @spec operation(t, atom | String.t(), payload, payload) :: t
  def operation(%__MODULE__{} = batch, type, meta \\ [], data) do
    %{batch | operations: [{type, meta, data} | batch.operations]}
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
