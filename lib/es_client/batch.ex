defmodule ESClient.Batch do
  defstruct items: []

  @type payload :: %{optional(atom | String.t()) => any}

  @type item :: {atom, payload, payload}
  @type t :: %__MODULE__{items: [item]}

  @spec operation(t, atom, payload, payload) :: t
  def operation(%__MODULE__{} = batch, type, data, meta \\ %{}) do
    %{batch | items: [{type, meta, data} | batch.items]}
  end

  defimpl ESClient.Encodable do
    def encode(batch, config) do
      data =
        batch.items
        |> Enum.reverse()
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
