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
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:combine, "~> 0.10.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      links: %{"GitHub" => "https://github.com/diasbruno/email_ex"},
      licenses: ["MIT"]
    ]
  end
end
