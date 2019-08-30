defmodule ESClient.ConfigRegistry do
  @moduledoc false

  use Agent

  alias ESClient.Config

  @initial_value %{}

  @spec start_link(Keyword.t()) :: Agent.on_start()
  def start_link(opts \\ []) do
    opts = Keyword.put(opts, :name, __MODULE__)
    Agent.start_link(fn -> @initial_value end, opts)
  end

  @spec lookup(atom, module) :: Config.t()
  def lookup(otp_app, client_mod) do
    key = {otp_app, client_mod}

    Agent.get_and_update(__MODULE__, fn configs ->
      case Map.fetch(configs, key) do
        {:ok, config} ->
          {config, configs}

        :error ->
          config = build_config(otp_app, client_mod)
          {config, Map.put(configs, key, config)}
      end
    end)
  end

  defp build_config(otp_app, client_mod) do
    otp_app
    |> Application.get_env(client_mod, [])
    |> Config.new()
  end

  @spec reset() :: :ok
  def reset do
    Agent.update(__MODULE__, fn _ -> @initial_value end)
  end
end
