defmodule ESClient.Config do
  @moduledoc """
  A helper module to retrieve configuration values and defaults for the client.
  """

  defstruct base_url: "http://localhost:9200",
            driver: ESClient.Drivers.HTTPoison,
            json_keys: :strings,
            json_library: Jason,
            timeout: 15_000

  @type t :: %__MODULE__{
          base_url: String.t() | URI.t(),
          driver: module,
          json_keys: :atoms | :atoms! | :strings,
          json_library: module,
          timeout: timeout
        }

  @doc """
  Builds a new config.

  ## Options

  * `:base_url` - The URL of the Elasticsearch endpoint. Defaults to
    `http://localhost:9200`.
  * `:driver` - The driver to use to transfer data from and to Elasticsearch.
    Defaults to `ESClient.Drivers.HTTPoison`.
  * `:json_keys` - Determines how to convert keys in decoded JSON objects.
    Possible values are `:atoms`, `:atoms!` and `strings` (default). Note that
    the JSON library has to support these options.
  * `:json_library` - The JSON library that encodes request data and decodes
    response data. Defaults to `Jason`.
  * `:timeout` - The time to wait before aborting a request. Can be a
    non-negative integer or `:infinity`. Defaults to 15000 (milliseconds).
  """
  @spec new(t | Keyword.t() | %{optional(atom) => any}) :: t
  def new(config_or_opts)
  def new(%__MODULE__{} = config), do: config
  def new(opts), do: struct(__MODULE__, opts)
end
