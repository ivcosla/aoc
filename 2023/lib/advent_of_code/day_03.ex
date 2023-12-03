defmodule AdventOfCode.Day03 do
  @numbers Enum.map(0..9, fn n -> "#{n}" end)
  @numbers_regex ~r/\d+/

  def part1(text) do
    enumerated_lines =
      String.split(text, "\n", trim: true)
      |> Enum.with_index(&{&2, &1})

    grid = enumerated_lines_to_grid(enumerated_lines)

    visited = build_visited(grid)

    visited =
      Enum.reduce(
        enumerated_lines,
        visited,
        fn {i, line}, acc ->
          graphemes_with_index =
            String.graphemes(line)
            |> Enum.with_index(&{&2, &1})

          traverse_updating(grid, acc, {i, graphemes_with_index})
        end
      )

    Enum.filter(visited, fn {_k, v} -> v end)
    |> Enum.map(fn {{val, _, _}, _} -> String.to_integer(val) end)
    |> Enum.sum()
  end

  def part2(text) do
    enumerated_lines =
      String.split(text, "\n", trim: true)
      |> Enum.with_index(&{&2, &1})

    grid = enumerated_lines_to_grid(enumerated_lines)

    Enum.reduce(
      enumerated_lines,
      [],
      fn {i, line}, acc ->
        graphemes_with_index =
          String.graphemes(line)
          |> Enum.with_index(&{&2, &1})

        traverse_gears(grid, acc, {i, graphemes_with_index})
      end
    )
    |> Enum.sum()
  end

  # Part 2 specific -----------------------------------
  def traverse_gears(_grid, visited, {_i, []}), do: visited

  def traverse_gears(grid, visited, {i, line}) do
    [h | rest] = line

    case h do
      {y, "*"} ->
        traverse_gears(
          grid,
          add_ratio_if_two_neighbors(grid, visited, i, y),
          {i, rest}
        )

      _ ->
        traverse_gears(grid, visited, {i, rest})
    end
  end

  def add_ratio_if_two_neighbors(grid, visited, x, y) do
    total =
      for px <- (x - 1)..(x + 1), py <- (y - 1)..(y + 1) do
        maybe_pick_neighbours(grid[px][py])
      end
      |> List.flatten()
      |> Enum.uniq()

    if length(total) === 2 do
      total = Enum.map(total, fn {val, _, _} -> String.to_integer(val) end)
      visited ++ [Enum.at(total, 0) * Enum.at(total, 1)]
    else
      visited
    end
  end

  def maybe_pick_neighbours(grid_value) do
    case grid_value do
      nil ->
        []

      val ->
        [val]
    end
  end

  # Part 1 specific -----------------------------------
  def traverse_updating(_grid, visited, {_i, []}), do: visited

  def traverse_updating(grid, visited, {i, line}) do
    [h | rest] = line

    case h do
      {_, "."} ->
        traverse_updating(grid, visited, {i, rest})

      {y, val} ->
        if Enum.member?(@numbers, val) do
          traverse_updating(grid, visited, {i, rest})
        else
          traverse_updating(
            grid,
            update_each_neighbor(grid, visited, i, y),
            {i, rest}
          )
        end
    end
  end

  def update_each_neighbor(grid, visited, x, y) do
    neighbors = for px <- (x - 1)..(x + 1), py <- (y - 1)..(y + 1), do: {px, py}

    Enum.reduce(
      neighbors,
      visited,
      fn {px, py}, acc -> update_if_not_nil(acc, grid[px][py]) end
    )
  end

  def update_if_not_nil(visited, grid_value) do
    if is_nil(grid_value) or is_nil(visited[grid_value]) do
      visited
    else
      Map.put(visited, grid_value, true)
    end
  end

  def build_visited(grid) do
    all_numbers = Map.values(grid) |> Enum.flat_map(&Map.values/1) |> Enum.uniq()

    Map.new(all_numbers, fn n -> {n, false} end)
  end

  # -----------------------------------

  def enumerated_lines_to_grid(enumerated_lines) do
    Enum.map(
      enumerated_lines,
      fn {n, l} -> {n, line_to_mapped_numbers(n, l)} end
    )
    |> Map.new()
  end

  def line_to_mapped_numbers(n, l) do
    # shape [[{1, 2}], [{3,1}]]
    # first digit is the position in the line, second is the length of the match
    matches = Regex.scan(@numbers_regex, l, return: :index)

    Enum.flat_map(matches, fn m ->
      {start, len} = Enum.at(m, 0)

      # we annotate each number with the starting position, as they can be
      # duplicated
      number_in_match = {String.slice(l, start, len), n, start}

      # map each position where the number exists to the number itself
      Enum.zip(start..(start + len - 1), Stream.cycle([number_in_match]))
    end)
    |> Map.new()
  end
end
