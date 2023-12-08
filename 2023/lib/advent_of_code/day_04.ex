defmodule AdventOfCode.Day04 do
  def part1(text) do
    lines = String.split(text, "\n", trim: true)

    Enum.reduce(
      lines,
      0,
      fn l, acc ->
        {_, winning, have} = get_parts(l)
        power = length(intersection(winning, have))

        if power > 0 do
          acc + 2 ** (power - 1)
        else
          acc
        end
      end
    )
  end

  def part2(text) do
    lines = String.split(text, "\n", trim: true)

    {_, total} =
      Enum.reduce(
        lines,
        {Map.new(), 0},
        fn l, {res_map, total} ->
          {card_number, winning, having} = get_parts(l)

          total_cards = Map.get(res_map, card_number, 1)

          to_duplicate = length(intersection(winning, having))

          if to_duplicate > 0 do
            res_map =
              Enum.reduce(
                (card_number + 1)..(card_number + to_duplicate),
                res_map,
                fn n, acc ->
                  Map.update(
                    acc,
                    n,
                    total_cards + 1,
                    fn existing_value ->
                      existing_value + total_cards
                    end
                  )
                end
              )

            {res_map, total + total_cards}
          else
            {res_map, total + total_cards}
          end
        end
      )

    total
  end

  def get_parts(l) do
    ["Card " <> card_number, numbers] = String.split(l, ":")
    [winning_raw, have_raw] = String.split(numbers, "|")

    {String.to_integer(String.trim(card_number)), to_nums(winning_raw), to_nums(have_raw)}
  end

  def intersection(l1, l2) do
    MapSet.intersection(
      MapSet.new(l1),
      MapSet.new(l2)
    )
    |> MapSet.to_list()
  end

  def to_nums(raw_line),
    do: String.split(raw_line, " ", trim: true) |> Enum.map(&String.to_integer/1)
end
