defmodule EmailEx do
  @moduledoc """
  E-mail parser and validation according to rfc-2822.
  """
  use Combine
  alias EmailEx.RFC2822

  @doc """
  Parse a address string.

    iex> EmailEx.parse(nil)
    {:error, "Expected address to parse."}

    iex> EmailEx.parse("")
    {:error, "Expected address to parse."}

    iex> EmailEx.parse("a@a.com")
    {:ok, ["a", "@", "a.com"]}

  """
  def parse(nil), do: {:error, "Expected address to parse."}
  def parse(""), do: {:error, "Expected address to parse."}
  def parse(str) do
    case Combine.parse(str, RFC2822.local_part() |> char("@") |> RFC2822.domain) do
      {:error, _} = error -> error
      value -> {:ok, value}
    end
  end

  @doc """
  Check if an e-mail is valid.

    iex> EmailEx.valid?(nil)
    false

    iex> EmailEx.valid?("")
    false

    iex> EmailEx.parse("a@a.com")
    true

  """
  def valid?(nil), do: false
  def valid?(""), do: false
  def valid?(email) do
    case parse(email) do
      {:error, _} -> false
      _ -> true
    end
  end
end
