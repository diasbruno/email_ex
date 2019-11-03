defmodule EmailEx do
  @moduledoc """
  E-mail parser and validation.
  """
  use Combine
  alias EmailEx.RFC2822

  @doc """
  Parse an address string.


  ## Examples

    iex> EmailEx.parse(nil)
    {:error, reason}

    iex> EmailEx.parse("")
    {:error, reason}

    iex> EmailEx.parse("a@a.com")
    {:ok, results}

  """
  @doc since: "0.1.0"
  @spec parse(String.t) :: {:ok, [String.t]} | {:error, String.t}
  def parse(nil), do: {:error, "Expected address to parse."}

  def parse(""), do: {:error, "Expected address to parse."}

  def parse(str) do
    case Combine.parse(str, RFC2822.local_part() |> char("@") |> RFC2822.domain) do
      {:error, _} = error -> error
      value -> {:ok, value}
    end
  end

  @doc """
  Check if an address is valid.


  ## Examples

    iex> EmailEx.valid?(nil)
    false

    iex> EmailEx.valid?("")
    false

    iex> EmailEx.parse("a@a.com")
    true

  """
  @doc since: "0.1.0"
  @spec valid?(String.t) :: true | false
  def valid?(nil),
    do: false

  def valid?(""),
    do: false

  def valid?(email) do
    case parse(email) do
      {:error, _} -> false
      _ -> true
    end
  end
end
