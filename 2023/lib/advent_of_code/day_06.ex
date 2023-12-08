defmodule AdventOfCode.Day06 do
  def part1(text) do
    get_parts_p1(text)
    |> Enum.map(fn race ->
      time = elem(race, 0)
      s_start = possible_solutions_from_start(race, {0, 0})
      s_end = possible_solutions_from_end(race, {time, 0})

      s_end - s_start + 1
    end)
    |> Enum.product()
  end

  def part2(text) do
    race = get_parts_p2(text)

    time = elem(race, 0)

    s_start = possible_solutions_from_start(race, {0, 0})
    s_end = possible_solutions_from_end(race, {time, 0})

    s_end - s_start + 1
  end

  def possible_solutions_from_start({time, distance}, {speed, res}) do
    result = time * speed

    cond do
      # early return if we found solutions already but we can win no more
      res > 0 ->
        res

      result > distance ->
        possible_solutions_from_start(
          {time - 1, distance},
          {speed + 1, speed}
        )

      true ->
        possible_solutions_from_start({time - 1, distance}, {speed + 1, res})
    end
  end

  def possible_solutions_from_end({time, distance}, {speed, res}) do
    time_left = time - speed
    result = time_left * speed

    cond do
      # early return if we found solutions already but we can win no more
      res > 0 ->
        res

      result > distance ->
        possible_solutions_from_end(
          {time, distance},
          {speed - 1, speed}
        )

      true ->
        possible_solutions_from_end({time, distance}, {speed - 1, res})
    end
  end

  def get_parts_p1(str) do
    [
      "Time:" <> times_raw,
      "Distance:" <> distances_raw
    ] = String.split(str, "\n", trim: true)

    times = String.split(times_raw, " ", trim: true) |> Enum.map(&String.to_integer/1)
    distances = String.split(distances_raw, " ", trim: true) |> Enum.map(&String.to_integer/1)

    Enum.zip(times, distances)
  end

  def get_parts_p2(str) do
    [
      "Time:" <> times_raw,
      "Distance:" <> distances_raw
    ] = String.split(str, "\n", trim: true)

    time =
      String.trim(times_raw) |> String.replace(" ", "") |> String.to_integer()

    distance =
      String.trim(distances_raw)
      |> String.replace(" ", "")
      |> String.to_integer()

    {time, distance}
  end
end
