defmodule AdventOfCode.Day07 do
  @cards_p1 Enum.with_index(["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"])
            |> Map.new()
  @cards_p2 Enum.with_index(["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"])
            |> Map.new()
  def part1(text) do
    get_parts(text, @cards_p1)
    |> Enum.sort(fn {hand1, _}, {hand2, _} ->
      card_sorting(hand1, hand2, fn h -> get_hand_play_p1(h) end)
    end)
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_, bid}, rank}, acc ->
      acc + rank * bid
    end)
  end

  def part2(text) do
    get_parts(text, @cards_p2)
    |> Enum.sort(fn {hand1, _}, {hand2, _} ->
      card_sorting(hand1, hand2, fn h -> get_hand_play_p2(h) end)
    end)
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_, bid}, rank}, acc ->
      acc + rank * bid
    end)
  end

  def get_hand_play_p2(hand) do
    graphemes_only = Enum.map(hand, fn {h, _} -> h end)
    freqs = Enum.frequencies(graphemes_only)

    jokers = Map.get(freqs, "J", 0)
    rest_of_freqs = Map.delete(freqs, "J")

    without_joker =
      rest_of_freqs
      |> Map.values()
      |> Enum.sort(:desc)

    pairings =
      if length(without_joker) > 0 do
        [x | rest] = without_joker
        [x + jokers | rest]
      else
        [5]
      end

    case pairings do
      [5] -> 7
      [4, 1] -> 6
      [3, 2] -> 5
      [3, 1, 1] -> 4
      [2, 2, 1] -> 3
      [2, 1, 1, 1] -> 2
      _ -> 1
    end
  end

  def get_hand_play_p1(hand) do
    pairings =
      Enum.frequencies(hand)
      |> Map.values()
      |> Enum.sort(:desc)

    case pairings do
      [5] -> 7
      [4, 1] -> 6
      [3, 2] -> 5
      [3, 1, 1] -> 4
      [2, 2, 1] -> 3
      [2, 1, 1, 1] -> 2
      _ -> 1
    end
  end

  def card_sorting(hand1, hand2, compute_play) do
    play1 = compute_play.(hand1)
    play2 = compute_play.(hand2)

    cond do
      play1 < play2 ->
        false

      play1 > play2 ->
        true

      true ->
        Enum.zip(
          hand1,
          hand2
        )
        |> Enum.reduce_while(
          nil,
          fn {card1, card2}, acc ->
            res = compare_cards(card1, card2)

            case res do
              :eq -> {:cont, acc}
              :ls -> {:halt, false}
              :gt -> {:halt, true}
            end
          end
        )
    end
  end

  def compare_cards({_, p1}, {_, p2}) do
    cond do
      p1 == p2 -> :eq
      p1 < p2 -> :ls
      p1 > p2 -> :gt
    end
  end

  def get_parts(text, mapper) do
    String.split(text, "\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ", trim: true)

      graphemes_with_power =
        String.graphemes(hand)
        |> Enum.map(fn g ->
          {g, Map.get(mapper, g)}
        end)

      {graphemes_with_power, String.to_integer(bid)}
    end)
  end
end
