defmodule JSONCodec do
  @moduledoc false

  @callback decode(any, Keyword.t()) :: {:ok, any} | {:error, Exception.t()}
  @callback encode(any) :: {:ok, any} | {:error, Exception.t()}
end
