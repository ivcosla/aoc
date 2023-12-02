defmodule AdventOfCode.Day02 do
  @part_1_validity %{
    red: 12,
    green: 13,
    blue: 14
  }

  def part1(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.map(&get_line_parts/1)
    |> Enum.map(&filter_valid_p1/1)
    |> Enum.filter(fn v -> v !== nil end)
    |> Enum.sum()
  end

  def part2(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.map(&get_line_parts/1)
    |> Enum.map(&get_minimum_set/1)
    |> Enum.map(&multiply_map_values/1)
    |> Enum.sum()
  end

  def filter_valid_p1(%{
        game: game,
        dice_scores: dice_scores
      }) do
    res =
      Enum.all?(
        dice_scores,
        fn s ->
          Enum.map(
            s,
            fn {color, number} ->
              number <= @part_1_validity[color]
            end
          )
          |> Enum.all?(fn is_minor -> is_minor end)
        end
      )

    if res do
      game
    else
      nil
    end
  end

  def get_minimum_set(%{game: _, dice_scores: scores}) do
    Enum.reduce(
      scores,
      %{
        blue: 1,
        green: 1,
        red: 1
      },
      fn s, acc ->
        m = Map.new(s)

        Map.merge(m, acc, fn _k, v1, v2 ->
          if v1 > v2 do
            v1
          else
            v2
          end
        end)
      end
    )
  end

  def get_line_parts(l) do
    [game, hands] = String.split(l, ":")

    hands_data = String.split(hands, ";")

    dice_scores =
      hands_data
      |> Enum.map(fn hand_data ->
        hand_data
        |> String.split(",")
        |> Enum.map(&dice_number/1)
      end)

    %{game: game_id(game), dice_scores: dice_scores}
  end

  def game_id("Game " <> x), do: String.to_integer(x)

  def dice_number(s) do
    case String.split(s) do
      [x, "blue"] -> {:blue, String.to_integer(x)}
      [x, "red"] -> {:red, String.to_integer(x)}
      [x, "green"] -> {:green, String.to_integer(x)}
    end
  end

  defp multiply_map_values(m) do
    Map.values(m)
    |> Enum.reduce(fn
      n, acc -> n * acc
    end)
  end
end
