defmodule ESClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :es_client,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:ex_unit, :mix]],
      description: description(),
      package: package(),

      # Docs
      name: "ESClient",
      source_url:
        "https://github.com/tlux/es_client/blob/master/%{path}#L%{line}",
      homepage_url: "https://github.com/tlux/es_client",
      docs: [
        main: "readme",
        extras: ["README.md"],
        groups_for_modules: []
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "A minimalistic Elasticsearch client for Elixir."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tlux/es_client"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:exvcr, "~> 0.10", only: :test},
      {:jason, "~> 1.1", optional: true},
      {:httpoison, "~> 1.5"},
      {:mox, "~> 0.5", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
