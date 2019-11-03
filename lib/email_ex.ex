defmodule EmailEx do
  @moduledoc """
  E-mail validation according to rfc-2822.
  """
  use Combine

  @atext ~r/[\!\#\$\%\&\*\+\-\/\=\?\^\_\`\|\{\}\~\'x[:alpha:][:digit:]]/

  defp no_ws_ctl(x),
    do: (x >= 1 and x < 9) or (x > 10 and x < 13) or (x > 13 and x < 32) or x == 127

  defp ctext(),
    do: satisfy(bits(8), fn <<x>> ->
          no_ws_ctl(x) or (x > 32 and x < 40) or (x > 41 and x < 92) or x > 93
        end)

  defp ccontent(),
    do: choice([ctext(), quoted_pair()])

  defp comment(),
    do: pipe([
          between(char("("), many(ccontent()), char(")"))
        ], fn x -> "(" <> Enum.join(x) <> ")" end)

  defp atext(),
    do: word_of(@atext)

  defp dot_atom_text(),
    do: pipe([
          option(comment()),
          many1(atext()),
          option(comment())
        ], &Enum.join/1)

  defp dot_part(),
    do: pipe([
          many(map(pair_both(
                    char("."),
                    dot_atom_text()
                  ), fn {a, b} -> a <> b end))],
          &Enum.join/1
        )

  defp dot_atom(),
    do: pipe([
          option(comment()),
          dot_atom_text(),
          option(dot_part()),
          option(comment())
        ], &Enum.join/1)

  defp text(),
    do: satisfy(bits(8), fn <<x>> ->
      (x > 1 and x < 9) or (x > 10 and x < 13) or x > 14
    end)

  defp quoted_pair(),
    do: pipe([char("\\"), text()], &Enum.join/1)

  defp qtext(),
    do: satisfy(bits(8), fn <<x>> ->
      x == 33 or (x > 34 and x < 92) or x > 92
    end)

  defp quoted_string(),
    do: pipe([
          between(
            char("\""),
            many1(choice([quoted_pair(), qtext()])),
            char("\"")
          )], fn x -> "\"" <> Enum.join(x) <> "\"" end)

  defp dtext(),
    do: satisfy(bits(8), fn <<x>> ->
      no_ws_ctl(x) or (x > 32 and x < 91) or x > 93
    end)

  defp dcontent(),
    do: choice([many1(dtext()), quoted_pair()])

  defp domain_literal(),
    do: between(char("["), dcontent(), char("]"))

  defp obs_domain(),
    do: dot_atom()

  defp domain(stuff),
    do: stuff |> choice([dot_atom(), domain_literal(), obs_domain()])

  defp atom(),
    do: pipe([
      option(comment()),
      many1(atext()),
      option(comment())
    ], &Enum.join/1)

  defp word_(),
    do: choice([atom(), quoted_string()])

  defp obs_local_part(),
    do: pipe([
          word_(),
          option([many(map(pair_both(
                             char("."),
                             word_()
                           ), fn {a, b} -> a <> b end))])
        ], &Enum.join/1)

  defp local_part(),
    do: pipe([
          choice([dot_atom(),
                  quoted_string(),
                  obs_local_part()])
        ], &Enum.join/1)

  @doc """
  """
  def parse(str), do: Combine.parse(str, local_part() |> char("@") |> domain)

  @doc """
  Check if an e-mail is valid.
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
