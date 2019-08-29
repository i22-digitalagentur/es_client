defmodule ESClient.Driver do
  @moduledoc """
  A behavior that must be implemented by custom Elasticsearch drivers. A driver
  sends a request to the Elasticsearch endpoint and retrieves the particular
  response.
  """

  @typedoc """
  A type representing request headers.
  """
  @type req_headers ::
          Keyword.t(binary)
          | [{String.t(), binary}]
          | %{optional(atom | String.t()) => binary}

  @typedoc """
  A type representing response headers.
  """
  @type resp_headers :: [{String.t(), binary}]

  @typedoc """
  A type representing successful response data.
  """
  @type resp :: %{
          required(:status_code) => non_neg_integer,
          required(:headers) => resp_headers,
          required(:body) => binary,
          optional(atom) => any
        }

  @typedoc """
  A type representing failed response data.
  """
  @type error :: %{:reason => any, optional(atom) => any}

  @doc """
  A callback for implementing an own function to send a request to a HTTP
  endpoint.
  """
  @callback request(
              verb :: ESClient.verb(),
              url :: URI.t(),
              body :: binary,
              headers :: req_headers,
              opts :: Keyword.t()
            ) :: {:ok, resp} | {:error, error}
end
