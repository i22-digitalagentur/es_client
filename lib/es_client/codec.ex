defmodule ESClient.Codec do
  @moduledoc false

  alias ESClient.CodecError
  alias ESClient.Config

  @doc """
  Decodes data using the JSON codec from the given config.
  """
  @spec decode(Config.t(), String.t(), any) ::
          {:ok, any} | {:error, CodecError.t()}
  def decode(config, content_type, data)

  def decode(_config, _content_type, nil), do: {:ok, nil}

  def decode(_config, _content_type, ""), do: {:ok, nil}

  def decode(config, "application/json", data) when is_binary(data) do
    with {:error, error} <- config.json_codec.decode(data, keys: :atoms) do
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
  Decodes data using the JSON codec from the given config. Raises when the
  decoding fails.
  """
  @spec decode!(Config.t(), String.t(), any) :: any | no_return
  def decode!(config, content_type, data) do
    case decode(config, content_type, data) do
      {:ok, decoded_data} -> decoded_data
      {:error, error} -> raise error
    end
  end

  @doc """
  Encodes data using the JSON codec from the given config.
  """
  @spec encode(Config.t(), any) :: {:ok, any} | {:error, CodecError.t()}
  def encode(config, data)

  def encode(_config, nil), do: {:ok, ""}

  def encode(_config, data) when is_binary(data), do: {:ok, data}

  def encode(config, data) do
    with {:error, error} <- config.json_codec.encode(data) do
      {:error,
       %CodecError{operation: :encode, data: data, original_error: error}}
    end
  end

  @doc """
  Encodes data using the JSON codec from the given config. Raises when the
  encoding fails.
  """
  @spec encode!(Config.t(), any) :: any | no_return
  def encode!(config, data) do
    case encode(config, data) do
      {:ok, encoded_data} -> encoded_data
      {:error, error} -> raise error
    end
  end
end
