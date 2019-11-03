defmodule EmailEx do
  @moduledoc """
  E-mail validation according rfc-2822.


  # Specification

  ## 3.4.1. Addr-spec specification

  https://tools.ietf.org/html/rfc2822#section-3.4.1
  https://tools.ietf.org/html/rfc5322#section-4.4
  https://tools.ietf.org/html/rfc6854
  """
  use Combine

  @atext ~r/[\!\#\$\%\&\*\+\-\/\=\?\^\_\`\|\{\}\~\'x[:alpha:][:digit:]]/

  def no_ws_ctl(x),
    do: (x >= 1 and x < 9) or (x > 10 and x < 13) or (x > 13 and x < 32) or x == 127

  # %d1-8 /         ; US-ASCII control characters
  # %d11 /          ;  that do not include the
  # %d12 /          ;  carriage return, line feed,
  # %d14-31 /       ;  and white space characters
  # %d127

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

  @doc """
  NO-WS-CTL       =       %d1-8 /         ; US-ASCII control characters
                          %d11 /          ;  that do not include the
                          %d12 /          ;  carriage return, line feed,
                          %d14-31 /       ;  and white space characters
                          %d127

  obs-FWS         =       1*WSP *(CRLF 1*WSP)
  FWS             =       ([*WSP CRLF] 1*WSP) /   ; Folding white space
                          obs-FWS

  ctext           =       NO-WS-CTL /     ; Non white space controls

                          %d33-39 /       ; The rest of the US-ASCII
                          %d42-91 /       ;  characters not including "(",
                          %d93-126        ;  ")", or "\"

  ccontent        =       ctext / quoted-pair / comment

  comment         =       "(" *([FWS] ccontent) [FWS] ")"

  CFWS            =       *([FWS] comment) (([FWS] comment) / FWS)

  atext           =       ALPHA / DIGIT / ; Any character except controls,
                          "!" / "#" /     ;  SP, and specials.
                          "$" / "%" /     ;  Used for atoms
                          "&" / "'" /
                          "*" / "+" /
                          "-" / "/" /
                          "=" / "?" /
                          "^" / "_" /
                          "`" / "{" /
                          "|" / "}" /
                          "~"

  atom            =       [CFWS] 1*atext [CFWS]
  word            =       atom / quoted-string
  obs-local-part  =       word *("." word)
  obs-domain      =       atom *("." atom)

  dot-atom        =       [CFWS] dot-atom-text [CFWS]

  dot-atom-text   =       1*atext *("." 1*atext)

  quoted-pair     =       ("\" text) / obs-qp
  dcontent        =       dtext / quoted-pair
  dtext           =       NO-WS-CTL /     ; Non white space controls

                          %d33-90 /       ; The rest of the US-ASCII
                          %d94-126        ;  characters not including "[",
                                          ;  "]", or "\"

  local-part      =       dot-atom / quoted-string / obs-local-part

  domain-literal  =       [CFWS] "[" *([FWS] dcontent) [FWS] "]" [CFWS]
  domain          =       dot-atom / domain-literal / obs-domain

  addr-spec       =       local-part "@" domain
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
