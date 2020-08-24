defprotocol ESClient.Encodable do
  @spec encode(t, ESClient.Config.t()) ::
          {:ok, content_type :: nil | String.t(), data :: String.t()}
          | :error
          | {:error, any}
  def encode(data, config)
end

defimpl ESClient.Encodable, for: [List, Map] do
  def encode(data, config) do
    with {:ok, encoded_data} <- config.json_library.encode(data) do
      {:ok, "application/json", encoded_data}
    end
  end
end
