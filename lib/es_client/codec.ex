defmodule ESClient.Codec do
  @moduledoc false

  alias ESClient.CodecError
  alias ESClient.Config
  alias ESClient.Encodable

  @doc """
  Decodes data using the JSON codec from the given config.
  """
  @spec decode(Config.t(), String.t(), any) ::
          {:ok, any} | {:error, CodecError.t()}
  def decode(config, content_type, data)

  def decode(_config, _content_type, nil), do: {:ok, nil}

  def decode(_config, _content_type, ""), do: {:ok, nil}

  def decode(config, "application/json", data) when is_binary(data) do
    with {:error, error} <-
           config.json_library.decode(data, keys: config.json_keys) do
      {:error,
       %CodecError{operation: :decode, data: data, original_error: error}}
    end
  end

  def decode(_config, _content_type, data) when is_binary(data) do
    {:ok, data}
  end

  def decode(_config, _content_type, data) do
    {:error, %CodecError{operation: :decode, data: data}}
  end

  @doc """
  Encodes data using the JSON codec from the given config.
  """
  @spec encode(Config.t(), any) ::
          {:ok, content_type :: nil | String.t(), Encodable.t()}
          | {:error, CodecError.t()}
  def encode(config, data)

  def encode(_config, nil), do: {:ok, nil, ""}

  def encode(config, data) do
    case Encodable.encode(data, config) do
      {:ok, content_type, encoded_data} ->
        {:ok, content_type, encoded_data}

      {:error, error} ->
        {:error,
         %CodecError{operation: :encode, data: data, original_error: error}}

      :error ->
        {:error, %CodecError{operation: :encode, data: data}}
    end
  end
end
