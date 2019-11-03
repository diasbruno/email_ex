defmodule EmailEx.RFC2822 do
  @moduledoc """
  E-mail parser and validation according to rfc-2822.
  """
  use Combine

  @atext ~r/[\!\#\$\%\&\*\+\-\/\=\?\^\_\`\|\{\}\~\'x[:alpha:][:digit:]]/

  def no_ws_ctl(x),
    do: (x >= 1 and x < 9) or (x > 10 and x < 13) or (x > 13 and x < 32) or x == 127

  def ctext(),
    do: satisfy(bits(8), fn <<x>> ->
          no_ws_ctl(x) or (x > 32 and x < 40) or (x > 41 and x < 92) or x > 93
        end)

  def ccontent(),
    do: choice([ctext(), quoted_pair()])

  def comment(),
    do: pipe([
          between(char("("), many(ccontent()), char(")"))
        ], fn x -> "(" <> Enum.join(x) <> ")" end)

  def atext(),
    do: word_of(@atext)

  def dot_atom_text(),
    do: pipe([
          option(comment()),
          many1(atext()),
          option(comment())
        ], &Enum.join/1)

  def dot_part(),
    do: pipe([
          many(map(pair_both(
                    char("."),
                    dot_atom_text()
                  ), fn {a, b} -> a <> b end))],
          &Enum.join/1
        )

  def dot_atom(),
    do: pipe([
          option(comment()),
          dot_atom_text(),
          option(dot_part()),
          option(comment())
        ], &Enum.join/1)

  def text(),
    do: satisfy(bits(8), fn <<x>> ->
      (x > 1 and x < 9) or (x > 10 and x < 13) or x > 14
    end)

  def quoted_pair(),
    do: pipe([char("\\"), text()], &Enum.join/1)

  def qtext(),
    do: satisfy(bits(8), fn <<x>> ->
      x == 33 or (x > 34 and x < 92) or x > 92
    end)

  def quoted_string(),
    do: pipe([
          between(
            char("\""),
            many1(choice([quoted_pair(), qtext()])),
            char("\"")
          )], fn x -> "\"" <> Enum.join(x) <> "\"" end)

  def dtext(),
    do: satisfy(bits(8), fn <<x>> ->
      no_ws_ctl(x) or (x > 32 and x < 91) or x > 93
    end)

  def dcontent(),
    do: choice([many1(dtext()), quoted_pair()])

  def domain_literal(),
    do: between(char("["), dcontent(), char("]"))

  def obs_domain(),
    do: dot_atom()

  def domain(stuff),
    do: stuff |> choice([dot_atom(), domain_literal(), obs_domain()])

  def atom(),
    do: pipe([
      option(comment()),
      many1(atext()),
      option(comment())
    ], &Enum.join/1)

  def word_(),
    do: choice([atom(), quoted_string()])

  def obs_local_part(),
    do: pipe([
          word_(),
          option([many(map(pair_both(
                             char("."),
                             word_()
                           ), fn {a, b} -> a <> b end))])
        ], &Enum.join/1)

  def local_part(),
    do: pipe([
          choice([dot_atom(),
                  quoted_string(),
                  obs_local_part()])
        ], &Enum.join/1)
end
