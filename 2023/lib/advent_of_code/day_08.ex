defmodule AdventOfCode.Day08 do
  def part1(text) do
    {dirs, map} = get_parts(text)

    Stream.cycle(dirs)
    |> Enum.reduce_while(
      {"AAA", 0},
      fn dir, {pos, total} ->
        next = apply_dir(dir, map[pos])

        case next do
          "ZZZ" -> {:halt, total + 1}
          _ -> {:cont, {next, total + 1}}
        end
      end
    )
  end

  def part2(text) do
    # lcm implementation is copied
    gcd = fn
      a, b, recur when a < b -> recur.(b, a, recur)
      a, b, _recur when rem(a, b) == 0 -> b
      a, b, recur -> recur.(b, rem(a, b), recur)
    end

    lcm = fn a, b ->
      div(a * b, gcd.(a, b, gcd))
    end

    {dirs, map} = get_parts(text)

    starters = get_ending_in_a(map)

    Enum.map(starters, fn start ->
      Stream.cycle(dirs)
      |> Enum.reduce_while(
        {start, 0},
        fn dir, {pos, total} ->
          next = apply_dir(dir, map[pos])

          if String.ends_with?(next, "Z") do
            {:halt, total + 1}
          else
            {:cont, {next, total + 1}}
          end
        end
      )
    end)
    |> Enum.reduce(1, fn res, acc -> lcm.(res, acc) end)
  end

  def apply_dir("L", {l, _}), do: l
  def apply_dir("R", {_, r}), do: r

  def get_ending_in_a(map) do
    Map.keys(map)
    |> Enum.filter(fn p -> String.ends_with?(p, "A") end)
  end

  def get_parts(text) do
    [raw_directions, raw_nodes] = String.split(text, "\n\n", trim: true)

    nodes =
      String.split(raw_nodes, "\n", trim: true)
      |> Enum.map(fn l ->
        [pos, dest_tuple] = String.split(l, " = ", trim: true)

        [dest_left, dest_right] =
          dest_tuple
          |> String.replace("(", "")
          |> String.replace(")", "")
          |> String.split(", ", trim: true)

        {pos, {dest_left, dest_right}}
      end)

    {String.graphemes(raw_directions), Map.new(nodes)}
  end
end
