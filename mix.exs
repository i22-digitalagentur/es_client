defmodule ESClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :es_client,
      version: "2.0.0",
      elixir: "~> 1.15",
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
        "https://github.com/i22-digitalagentur/es_client/blob/master/%{path}#L%{line}",
      homepage_url: "https://github.com/i22-digitalagentur/es_client",
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
        "GitHub" => "https://github.com/i22-digitalagentur/es_client",
        "GitHubOriginal" => "https://github.com/tlux/es_client"
      },
      maintainers: [
        "Kilian Gärtner",
        "Norbert Melzer"
      ],
      original_maintainers: [
        "Tobias Casper"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:excoveralls, "~> 0.16", only: :test},
      {:exvcr, "~> 0.14", only: :test},
      {:jason, "~> 1.4", optional: true},
      {:httpoison, "~> 2.0"},
      {:mox, "~> 1.0", only: :test}
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
