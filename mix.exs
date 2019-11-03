defmodule EmailEx.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :email_ex,
      version: @version,
      elixir: "~> 1.9",
      description: "Address specification parser (RFC2822).",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:combine, "~> 0.10.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp package() do
    [
      links: %{"GitHub" => "https://github.com/diasbruno/email_ex"},
      licenses: ["MIT"]
    ]
  end
end
