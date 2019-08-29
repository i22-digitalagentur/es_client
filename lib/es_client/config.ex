defmodule ESClient.Config do
  @moduledoc """
  A helper module to retrieve configuration values and defaults for the client.
  """

  defstruct base_url: "http://localhost:9200",
            driver: ESClient.Drivers.HTTPoison,
            json_codec: Jason,
            timeout: 15_000,
            wait_for_refresh: true

  @type t :: %__MODULE__{
          base_url: String.t() | URI.t(),
          driver: module,
          json_codec: module,
          timeout: timeout,
          wait_for_refresh: boolean
        }

  @doc """
  Builds a new config.
  """
  @spec new(t | Keyword.t() | %{optional(atom) => any}) :: t
  def new(config_or_opts)
  def new(%__MODULE__{} = config), do: config
  def new(opts), do: struct(__MODULE__, opts)
end
