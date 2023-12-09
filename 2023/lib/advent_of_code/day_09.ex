defmodule AdventOfCode.Day09 do
  def part1(text) do
    input = get_parts(text)

    Enum.reduce(
      input,
      0,
      fn input_seq, acc ->
        all_seqs = all_sequences(input_seq, [input_seq])

        acc + guess_next(all_seqs)
      end
    )
  end

  def part2(text) do
    input = get_parts(text)

    Enum.reduce(
      input,
      0,
      fn input_seq, acc ->
        all_seqs = all_sequences(Enum.reverse(input_seq), [Enum.reverse(input_seq)])

        acc + guess_next(all_seqs)
      end
    )
  end

  def guess_next(seqs) do
    Enum.reverse(seqs)
    |> Enum.reduce(
      0,
      fn s, previous_last ->
        current_last = List.last(s)

        current_last + previous_last
      end
    )
  end

  def all_sequences(seq, acc) do
    res = single_diff_seq(seq)

    cond do
      Enum.all?(res, fn e -> e == 0 end) -> Enum.concat(acc, [res])
      true -> all_sequences(res, Enum.concat(acc, [res]))
    end
  end

  def single_diff_seq(seq) do
    Enum.chunk_every(seq, 2, 1, :discard)
    |> Enum.map(fn [e1, e2] ->
      e2 - e1
    end)
  end

  def get_parts(text) do
    String.split(text, "\n", trim: true)
    |> Enum.map(fn l ->
      String.split(l, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
