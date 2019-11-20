defmodule ESClient.Utils do
  @moduledoc false

  alias ESClient.Config

  @separator "/"

  @spec build_url(
          config :: Config.t(),
          location :: nil | ESClient.location()
        ) :: URI.t() | no_return
  def build_url(config, location)

  def build_url(%{base_url: nil}, _location) do
    raise ArgumentError, "Missing base URL"
  end

  def build_url(config, {path, query}) do
    base_url = URI.parse(config.base_url)

    %{
      base_url
      | path: build_path(base_url.path, path),
        query: build_query(query)
    }
  end

  def build_url(config, path) do
    build_url(config, {path, nil})
  end

  defp build_query(nil), do: nil

  defp build_query(query) do
    case URI.encode_query(query) do
      "" -> nil
      query -> query
    end
  end

  defp build_path(base_path, path) do
    segments = normalize_path(base_path) ++ normalize_path(path)
    @separator <> Enum.join(segments, @separator)
  end

  defp normalize_path(nil), do: []

  defp normalize_path(segments) when is_list(segments), do: segments

  defp normalize_path(path) do
    String.split(path, @separator, trim: true)
  end

  @spec runtime_config?() :: boolean
  def runtime_config? do
    case Application.fetch_env(:es_client, :allow_runtime_config) do
      {:ok, runtime_config?} -> runtime_config?
      :error -> test_env?()
    end
  end

  defp test_env? do
    function_exported?(Mix, :env, 0) && Mix.env() == :test
  end
end
