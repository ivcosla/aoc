defmodule AdventOfCode.Day03 do
  @numbers Enum.map(0..9, fn n -> "#{n}" end)
  @numbers_regex ~r/\d+/

  def part1(text) do
    lines = String.split(text, "\n", trim: true)
    line_numbers = 0..(length(lines) - 1)

    enumerated_lines = Enum.zip(line_numbers, lines)

    grid = enumerated_lines_to_grid(enumerated_lines)

    visited = build_visited(grid)

    visited =
      Enum.reduce(
        enumerated_lines,
        visited,
        fn {i, line}, acc ->
          graphemes = String.graphemes(line)
          grapheme_numbers = 0..(length(graphemes) - 1)

          enumerated = Enum.zip(grapheme_numbers, graphemes)

          traverse_updating(grid, acc, {i, enumerated})
        end
      )

    Enum.filter(visited, fn {_k, v} -> v end)
    |> Enum.map(fn {{val, _, _}, _} -> String.to_integer(val) end)
    |> Enum.sum()
  end

  def part2(text) do
    lines = String.split(text, "\n", trim: true)
    line_numbers = 0..(length(lines) - 1)

    enumerated_lines = Enum.zip(line_numbers, lines)

    grid = enumerated_lines_to_grid(enumerated_lines)

    Enum.reduce(
      enumerated_lines,
      [],
      fn {i, line}, acc ->
        graphemes = String.graphemes(line)
        grapheme_numbers = 0..(length(graphemes) - 1)

        enumerated = Enum.zip(grapheme_numbers, graphemes)

        traverse_gears(grid, acc, {i, enumerated})
      end
    )
    |> Enum.sum()
  end

  # Part 2 specific -----------------------------------
  def traverse_gears(_grid, visited, {_i, []}) do
    visited
  end

  def traverse_gears(grid, visited, {i, line}) do
    [h | rest] = line

    case h do
      {_, "."} ->
        traverse_gears(grid, visited, {i, rest})

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
      []
      |> maybe_pick_neighbours(grid[x - 1][y - 1])
      |> maybe_pick_neighbours(grid[x - 1][y + 1])
      |> maybe_pick_neighbours(grid[x - 1][y])
      |> maybe_pick_neighbours(grid[x][y - 1])
      |> maybe_pick_neighbours(grid[x][y + 1])
      |> maybe_pick_neighbours(grid[x + 1][y - 1])
      |> maybe_pick_neighbours(grid[x + 1][y + 1])
      |> maybe_pick_neighbours(grid[x + 1][y])
      |> Enum.uniq()

    if length(total) === 2 do
      total = Enum.map(total, fn {val, _, _} -> String.to_integer(val) end)
      visited ++ [Enum.at(total, 0) * Enum.at(total, 1)]
    else
      visited
    end
  end

  def maybe_pick_neighbours(total, grid_value) do
    case grid_value do
      nil ->
        total

      val ->
        total ++ [val]
    end
  end

  # Part 1 specific -----------------------------------
  def traverse_updating(_grid, visited, {_i, []}) do
    visited
  end

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
    visited
    |> update_if_not_nil(grid[x - 1][y - 1])
    |> update_if_not_nil(grid[x - 1][y + 1])
    |> update_if_not_nil(grid[x - 1][y])
    |> update_if_not_nil(grid[x][y - 1])
    |> update_if_not_nil(grid[x][y + 1])
    |> update_if_not_nil(grid[x + 1][y - 1])
    |> update_if_not_nil(grid[x + 1][y + 1])
    |> update_if_not_nil(grid[x + 1][y])
  end

  def update_if_not_nil(visited, grid_value) do
    case grid_value do
      nil ->
        visited

      _ ->
        case visited[grid_value] do
          nil ->
            visited

          _val ->
            Map.put(visited, grid_value, true)
        end
    end
  end

  def build_visited(grid) do
    all_numbers = Map.values(grid) |> Enum.flat_map(&Map.values/1) |> Enum.uniq()

    Enum.zip(all_numbers, Stream.cycle([false])) |> Map.new()
  end

  # -----------------------------------

  def enumerated_lines_to_grid(enumerated_lines) do
    Enum.map(
      enumerated_lines,
      fn {n, l} ->
        {n, line_to_mapped_numbers(n, l)}
      end
    )
    |> Map.new()
  end

  def line_to_mapped_numbers(n, l) do
    # shape [[{1, 2}], [{3,1}]]
    # first digit is the position in the line, second is the length of the match
    matches = Regex.scan(@numbers_regex, l, return: :index)

    Enum.flat_map(matches, fn m ->
      inner = Enum.at(m, 0)
      start = elem(inner, 0)
      len = elem(inner, 1)

      index_range = start..(start + len - 1)

      # we annotate each number with the starting position, as they can be
      # duplicated
      number_in_match = {String.slice(l, start, len), n, start}

      Enum.zip(index_range, Stream.cycle([number_in_match]))
    end)
    |> Map.new()
  end
end
