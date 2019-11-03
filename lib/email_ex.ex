defmodule EmailEx do
  @moduledoc """
  E-mail parser and validation.
  """
  use Combine
  alias EmailEx.RFC2822

  @doc """
  Parse an address string.
  """
  @doc since: "0.1.0"
  @spec parse(String.t) :: {:ok, [String.t]} | {:error, String.t | term}
  def parse(str), do: parse(str, RFC2822)

  @doc """
  Parse an address string with a custom parser.
  """
  @doc since: "0.2.1"
  @spec parse(String.t, Module.t) :: {:ok, [String.t]} | {:error, String.t | term}
  def parse(str, mod) do
    case apply(mod, :parse, [str]) do
      {:error, _} = error -> error
      value -> {:ok, value}
    end
  end

  @doc """
  Parse an address, and if fail, throws an exception
  """
  @doc since: "0.2.1"
  @spec parse!(String.t) :: {:ok, [String.t]}
  def parse!(str), do: parse!(str, RFC2822)

  @doc """
  Parse an address string with a custom parser.
  """
  @doc since: "0.2.1"
  @spec parse!(String.t, Module.t) :: {:ok, [String.t]}
  def parse!(str, mod) do
    case parse(str, mod) do
      {:error, reason} -> raise EmailExError, message: reason
      value -> value
    end
  end

  @doc """
  Check if an address is valid.

  ## Examples

    iex> EmailEx.valid? nil
    false

    iex> EmailEx.valid? ""
    false

    iex> EmailEx.parse "a@a.com"
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
