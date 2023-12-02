defmodule AdventOfCode.Day01 do
  @valid_chars Enum.map(1..9, fn n -> "#{n}" end)
  @valid_words [
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine"
  ]
  @word_regex ~r"#{Enum.join(@valid_words ++ @valid_chars, "|")}"
  @word_to_int_map (Enum.zip(@valid_words, 1..9) ++ Enum.zip(@valid_chars, 1..9)) |> Map.new()

  def part1(text) do
    calibration_total =
      text
      |> String.split("\n", trim: true)
      |> Enum.map(&line_to_calibration(&1))
      |> Enum.sum()

    calibration_total
  end

  def part2(text) do
    IO.puts(inspect(@word_regex))
    IO.puts(inspect(@word_to_int_map))

    calibration_total =
      text
      |> String.split("\n", trim: true)
      |> Enum.map(&line_to_calibration_p2/1)
      |> Enum.sum()

    calibration_total
  end

  defp line_to_calibration(line) do
    digits =
      line
      |> String.graphemes()
      |> Enum.filter(fn c -> Enum.member?(@valid_chars, c) end)

    appended = List.first(digits) <> List.last(digits)

    String.to_integer(appended)
  end

  defp line_to_calibration_p2(line) do
    matches =
      all_possible_matches_in_line(line)
      |> Enum.map(fn match ->
        # Enum.at(0) because match looks like ["foo"]
        Map.get(@word_to_int_map, Enum.at(match, 0))
      end)

    appended = "#{List.first(matches)}#{List.last(matches)}"

    String.to_integer(appended)
  end

  defp all_possible_matches_in_line(line) do
    tokenized = String.graphemes(line)

    # In order to match everything, we look for matches in substrings
    # like ["oneight","neight","eight"], etc
    tokenized_sublists =
      Enum.scan(
        tokenized,
        tokenized,
        fn _, acc ->
          [_ | rest] = acc

          rest
        end
      )

    # the above result does not contains the full tokenized word, and
    # the last element is [], so we preprend the full word and get rid
    # of the last element
    tokenized_sublists = [tokenized] ++ drop_last(tokenized_sublists)

    substrings = Enum.map(tokenized_sublists, &List.to_string/1)

    Enum.map(
      substrings,
      fn s ->
        # using regex cause previous attempt used it, but this can be done
        # just checking if the word exists in our word + number list
        Regex.run(@word_regex, s)
      end
    )
    |> Enum.filter(fn m -> m !== nil end)
  end

  defp drop_last(l) do
    l |> Enum.reverse() |> tl() |> Enum.reverse()
  end
end
