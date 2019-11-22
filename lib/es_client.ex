defmodule ESClient do
  @moduledoc """
  A minimalistic Elasticsearch client for Elixir.

  ## Usage

  You can call the client directly if you have a config struct.

      iex> config = %ESClient.Config{base_url: "http://localhost:9201"}
      ...> ESClient.get!(config, "_cat/health")
      #ESClient.Response<...>

  It's also possible to pass a list of path segments.

      ESClient.get!(config, ["_cat", "health"])

  When the location is a tuple, the second element becomes encoded as query
  params.

      ESClient.get!(config, {["_cat", "health"], verbose: true})

  Alternatively, you can `use` this module to build your own custom client and
  obtain values from the application config.

      defmodule MyCustomClient
        use ESClient, otp_app: :my_app
      end

  Don't forget to add the configuration to your config.exs.

      use Mix.Config
      # or
      import Config

      config :my_app, MyCustomClient,
        base_url: "http://localhost:9201",
        json_keys: :atoms,
        json_library: Jason,
        timeout: 15_000

  Then, use your client.

      iex> MyCustomClient.get!("_cat/health")
      #ESClient.Response<...>
  """

  alias ESClient.Codec
  alias ESClient.CodecError
  alias ESClient.Config
  alias ESClient.RequestError
  alias ESClient.Response
  alias ESClient.ResponseError
  alias ESClient.Utils

  @typedoc """
  A type that refers to a HTTP method to perform the request with.
  """
  @type verb :: :head | :get | :post | :put | :delete

  @typedoc """
  A type that defines a String containing path segments separated by slashes.
  """
  @type path_str :: String.t()

  @typedoc """
  A type that defines a list of path segments.
  """
  @type path_segments :: [String.t()]

  @typedoc """
  A type that defines a String containing path segments separated by slashes or
  a list of path segments.
  """
  @type path :: path_str | path_segments

  @typedoc """
  A type that defines a location on the remote server, allowing optional query
  parameters.
  """
  @type location :: path | {path, query :: Enum.t()}

  @typedoc """
  A type that defines request data.
  """
  @type req_data ::
          String.t() | Keyword.t() | %{optional(atom | String.t()) => any}

  @typedoc """
  Type defining an error that be be returned or raised when sending a request to
  a resource.
  """
  @type error :: CodecError.t() | RequestError.t() | ResponseError.t()

  @doc """
  Dispatch a request to the path at the configured endpoint using the specified
  request method.
  """
  @callback request(verb, path) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a request to the path at the configured endpoint using the specified
  request method and data.
  """
  @callback request(verb, path, req_data) ::
              {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a request to the path at the configured endpoint using the specified
  request method. Raises when the request fails.
  """
  @callback request!(verb, location) :: Response.t() | no_return

  @doc """
  Dispatch a request to the path at the configured endpoint using the specified
  request method and data. Raises when the request fails.
  """
  @callback request!(verb, location, req_data) :: Response.t() | no_return

  @doc """
  Dispatch a HEAD request to the path at the configured endpoint.
  """
  @callback head(location) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a HEAD request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @callback head!(location) :: Response.t() | no_return

  @doc """
  Dispatch a GET request to the path at the configured endpoint.
  """
  @callback get(location) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a GET request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @callback get!(location) :: Response.t() | no_return

  @doc """
  Dispatch a POST request to the path at the configured endpoint.
  """
  @callback post(location) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a POST request to the path at the configured endpoint using the
  specified request data.
  """
  @callback post(location, req_data) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a POST request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @callback post!(location) :: Response.t() | no_return

  @doc """
  Dispatch a POST request to the path at the configured endpoint using the
  specified request data. Raises when the request fails.
  """
  @callback post!(location, req_data) :: Response.t() | no_return

  @doc """
  Dispatch a PUT request to the path at the configured endpoint.
  """
  @callback put(location) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a PUT request to the path at the configured endpoint using the
  specified request data.
  """
  @callback put(location, req_data) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a PUT request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @callback put!(location) :: Response.t() | no_return

  @doc """
  Dispatch a PUT request to the path at the configured endpoint using the
  specified request data. Raises when the request fails.
  """
  @callback put!(location, req_data) :: Response.t() | no_return

  @doc """
  Dispatch a DELETE request to the path at the configured endpoint.
  """
  @callback delete(location) :: {:ok, Response.t()} | {:error, error}

  @doc """
  Dispatch a DELETE request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @callback delete!(location) :: Response.t() | no_return

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote do
      @behaviour ESClient

      @doc false
      @spec __config__() :: Config.t()
      def __config__ do
        unquote(otp_app)
        |> Application.get_env(__MODULE__, [])
        |> Config.new()
      end

      @impl true
      def request(verb, location, req_data \\ nil) do
        ESClient.request(__config__(), verb, location, req_data)
      end

      @impl true
      def request!(verb, location, req_data \\ nil) do
        ESClient.request!(__config__(), verb, location, req_data)
      end

      @impl true
      def head(location) do
        ESClient.head(__config__(), location)
      end

      @impl true
      def head!(location) do
        ESClient.head!(__config__(), location)
      end

      @impl true
      def get(location) do
        ESClient.get(__config__(), location)
      end

      @impl true
      def get!(location) do
        ESClient.get!(__config__(), location)
      end

      @impl true
      def post(location, req_data \\ nil) do
        ESClient.post(__config__(), location, req_data)
      end

      @impl true
      def post!(location, req_data \\ nil) do
        ESClient.post!(__config__(), location, req_data)
      end

      @impl true
      def put(location, req_data \\ nil) do
        ESClient.put(__config__(), location, req_data)
      end

      @impl true
      def put!(location, req_data \\ nil) do
        ESClient.put!(__config__(), location, req_data)
      end

      @impl true
      def delete(location) do
        ESClient.delete(__config__(), location)
      end

      @impl true
      def delete!(location) do
        ESClient.delete!(__config__(), location)
      end

      defoverridable ESClient
    end
  end

  @doc """
  Sends a request with the given verb to the configured endpoint.

  ## Examples

      iex> ESClient.request(config, :get, "_cat/health")
      {:ok, %ESClient.Response{body: "..."}}

      iex> ESClient.request(config, :get, ["_cat", "health"])
      {:ok, %ESClient.Response{body: "..."}}

      iex> ESClient.request(config, :get, {["_cat", "invalid"], foo: "bar"})
      {:error, %ESClient.ResponseError{reason: "..."}}

      iex> ESClient.request(config, :put, "my-index", %{settings: %{...}})
      {:ok, %ESClient.Response{body: "..."}}
  """
  @spec request(config :: Config.t(), verb, location, nil | req_data) ::
          {:ok, Response.t()} | {:error, error}
  def request(%Config{} = config, verb, location, req_data \\ nil) do
    with {:ok, req_data} <- Codec.encode(config, req_data),
         {:ok, resp} <- do_request(config, verb, location, req_data),
         content_type = get_content_type(resp.headers),
         {:ok, resp_data} <- Codec.decode(config, content_type, resp.body) do
      build_resp(config, resp.status_code, content_type, resp_data)
    end
  end

  defp do_request(config, verb, location, req_data) do
    url = Utils.build_url(config, location)
    opts = [recv_timeout: config.timeout]

    case config.driver.request(verb, url, req_data, [], opts) do
      {:ok, resp} ->
        {:ok, resp}

      {:error, %{reason: reason}} ->
        {:error, %RequestError{reason: reason}}
    end
  end

  defp get_content_type(headers) do
    Enum.find_value(headers, fn
      {"content-type", content_type} ->
        content_type
        |> String.split(";")
        |> List.first()

      _ ->
        nil
    end)
  end

  defp build_resp(
         %{json_keys: :strings},
         status_code,
         _content_type,
         %{"error" => error} = data
       ) do
    {:error,
     %ResponseError{
       col: error["col"],
       line: error["line"],
       reason: error["reason"],
       type: error["type"],
       data: data,
       status_code: status_code
     }}
  end

  defp build_resp(_config, status_code, _content_type, %{error: error} = data) do
    {:error,
     %ResponseError{
       col: error[:col],
       line: error[:line],
       reason: error[:reason],
       type: error[:type],
       data: data,
       status_code: status_code
     }}
  end

  defp build_resp(_config, status_code, content_type, data) do
    {:ok,
     %Response{content_type: content_type, data: data, status_code: status_code}}
  end

  @doc """
  Dispatch a request to the path at the configured endpoint using the specified
  request method and data. Raises when the request fails.

  ## Examples

      iex> ESClient.request!(config, :get, "_cat/health")
      %ESClient.Response{body: "..."}

      iex> ESClient.request!(config, :get, ["_cat", "health"])
      %ESClient.Response{body: "..."}

      iex> ESClient.request!(config, :get, {["_cat", "invalid"], foo: "bar"})
      ** (ESClient.ResponseError) ...

      iex> ESClient.request!(config, :put, "my-index", %{settings: %{...}})
      %ESClient.Response{body: "..."}
  """
  @spec request!(Config.t(), verb, location, nil | req_data) ::
          Response.t() | no_return
  def request!(%Config{} = config, verb, location, req_data \\ nil) do
    case request(config, verb, location, req_data) do
      {:ok, resp} -> resp
      {:error, error} -> raise error
    end
  end

  @doc """
  Dispatch a HEAD request to the path at the configured endpoint.
  """
  @spec head(Config.t(), location) :: {:ok, Response.t()} | {:error, error}
  def head(%Config{} = config, location), do: request(config, :head, location)

  @doc """
  Dispatch a HEAD request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @spec head!(Config.t(), location) :: Response.t() | no_return
  def head!(%Config{} = config, location), do: request!(config, :head, location)

  @doc """
  Dispatch a GET request to the path at the configured endpoint.
  """
  @spec get(Config.t(), location) ::
          {:ok, Response.t()} | {:error, error}
  def get(%Config{} = config, location) do
    request(config, :get, location)
  end

  @doc """
  Dispatch a GET request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @spec get!(Config.t(), location) :: Response.t() | no_return
  def get!(%Config{} = config, location) do
    request!(config, :get, location)
  end

  @doc """
  Dispatch a POST request to the path at the configured endpoint using the
  specified request data.
  """
  @spec post(Config.t(), location, nil | req_data) ::
          {:ok, Response.t()} | {:error, error}
  def post(%Config{} = config, location, req_data \\ nil) do
    request(config, :post, location, req_data)
  end

  @doc """
  Dispatch a POST request to the path at the configured endpoint using the
  specified request data. Raises when the request fails.
  """
  @spec post!(Config.t(), location, nil | req_data) ::
          Response.t() | no_return
  def post!(%Config{} = config, location, req_data \\ nil) do
    request!(config, :post, location, req_data)
  end

  @doc """
  Dispatch a PUT request to the path at the configured endpoint using the
  specified request data.
  """
  @spec put(Config.t(), location, nil | req_data) ::
          {:ok, Response.t()} | {:error, error}
  def put(%Config{} = config, location, req_data \\ nil) do
    request(config, :put, location, req_data)
  end

  @doc """
  Dispatch a PUT request to the path at the configured endpoint using the
  specified request data. Raises when the request fails.
  """
  @spec put!(Config.t(), location, nil | req_data) ::
          Response.t() | no_return
  def put!(%Config{} = config, location, req_data \\ nil) do
    request!(config, :put, location, req_data)
  end

  @doc """
  Dispatch a GET request to the path at the configured endpoint.
  """
  @spec delete(Config.t(), location) ::
          {:ok, Response.t()} | {:error, error}
  def delete(%Config{} = config, location) do
    request(config, :delete, location)
  end

  @doc """
  Dispatch a GET request to the path at the configured endpoint. Raises when
  the request fails.
  """
  @spec delete!(Config.t(), location) :: Response.t() | no_return
  def delete!(%Config{} = config, location) do
    request!(config, :delete, location)
  end
end
