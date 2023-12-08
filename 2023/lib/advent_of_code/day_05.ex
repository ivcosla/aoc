defmodule AdventOfCode.Day05 do
  def part1(text) do
    parts = get_parts(text)

    find_smallest_location_for_list(parts[:seeds], parts)
  end

  def part2(text) do
    parts = get_parts(text)

    seeds =
      parse_seeds_into_pairs(parts[:seeds], [])

    {res, _} =
      find_mapping_of_range(seeds, parts[:seed_to_soil])
      |> find_mapping_of_range(parts[:soil_to_fertilizer])
      |> find_mapping_of_range(parts[:fertilizer_to_water])
      |> find_mapping_of_range(parts[:water_to_light])
      |> find_mapping_of_range(parts[:light_to_temperature])
      |> find_mapping_of_range(parts[:temperature_to_humidity])
      |> find_mapping_of_range(parts[:humidity_to_location])
      |> List.first()

    res
  end

  def find_smallest_location_for_list(list, parts) do
    Enum.reduce(
      list,
      fn seed, acc ->
        dst =
          find_matching_in_mapping(seed, parts[:seed_to_soil])
          |> find_matching_in_mapping(parts[:soil_to_fertilizer])
          |> find_matching_in_mapping(parts[:fertilizer_to_water])
          |> find_matching_in_mapping(parts[:water_to_light])
          |> find_matching_in_mapping(parts[:light_to_temperature])
          |> find_matching_in_mapping(parts[:temperature_to_humidity])
          |> find_matching_in_mapping(parts[:humidity_to_location])

        cond do
          acc == nil ->
            dst

          dst < acc ->
            dst

          true ->
            acc
        end
      end
    )
  end

  def find_mapping_of_range(range, mapping) do
    subranges = Enum.flat_map(range, &compute_subranges(&1, mapping))

    res =
      Enum.map(subranges, fn {s, d} ->
        transalted_s = find_matching_in_mapping(s, mapping)
        transalted_d = find_matching_in_mapping(d, mapping)
        {transalted_s, transalted_d}
      end)

    res
    |> Enum.sort(fn {start1, _}, {start2, _} -> start1 < start2 end)
  end

  def parse_seeds_into_pairs([], acc),
    do: Enum.sort(acc, fn {start1, _}, {start2, _} -> start1 < start2 end)

  def parse_seeds_into_pairs(seeds, acc) do
    [start, range | rest] = seeds

    parse_seeds_into_pairs(rest, acc ++ [{start, start + range - 1}])
  end

  def compute_subranges({start, dst}, mapping) do
    indexed_map_of_ranges =
      Enum.map(mapping, fn %{start: m_start, range: range} ->
        delta =
          if range > 0 do
            range - 1
          else
            0
          end

        m_dst = m_start + delta

        {m_start, m_dst}
      end)
      |> Enum.sort(fn {start1, _}, {start2, _} -> start1 < start2 end)
      |> Enum.with_index()

    result =
      Enum.reduce(
        indexed_map_of_ranges,
        [],
        fn {{m_start, m_dst}, index}, acc ->
          res = compare_ranges({start, dst}, {m_start, m_dst})

          {{_p_start, p_dst}, _} =
            if index - 1 < 0 do
              {{-1, -1}, 0}
            else
              Enum.at(indexed_map_of_ranges, index - 1)
            end

          {{n_start, _n_dst}, _} =
            if index + 1 >= length(mapping) do
              {{dst + 1, dst + 1}, 0}
            else
              Enum.at(indexed_map_of_ranges, index + 1)
            end

          maybe_previous =
            if p_dst + 1 == m_start do
              nil
            else
              {max(p_dst + 1, start), min(m_start - 1, dst)}
            end

          maybe_next =
            if m_dst + 1 == n_start do
              nil
            else
              {max(m_dst + 1, start), min(n_start - 1, dst)}
            end

          case res do
            :included ->
              Enum.concat(acc, [{start, dst}])

            :includes ->
              Enum.concat(acc, [
                maybe_previous,
                {m_start, m_dst},
                maybe_next
              ])

            :extends_dst ->
              Enum.concat(acc, [
                {start, m_dst},
                maybe_next
              ])

            :extends_start ->
              Enum.concat(acc, [
                {m_start, dst},
                maybe_previous
              ])

            _ ->
              acc
          end
        end
      )
      |> Enum.filter(&(&1 !== nil))

    if length(result) === 0 do
      [{start, dst}]
    else
      result
    end
  end

  def compare_ranges({start1, dst1}, {start2, dst2}) do
    cond do
      start1 > dst2 -> :after
      dst1 < start2 -> :before
      start1 >= start2 and dst1 <= dst2 -> :included
      start2 >= start1 and dst2 <= dst1 -> :includes
      start1 >= start2 and dst1 > dst2 -> :extends_dst
      start1 < start2 and dst1 <= dst2 -> :extends_start
      true -> raise "Unknown range check s1 #{start1}, d1 #{dst1}, s2 #{start2}, d2 #{dst2}"
    end
  end

  def get_parts(text) do
    parts = String.split(text, "\n\n", trim: true)

    [
      "seeds: " <> seeds_part,
      "seed-to-soil map:\n" <> seed_to_soil_part,
      "soil-to-fertilizer map:\n" <> soil_to_fertilizer_part,
      "fertilizer-to-water map:\n" <> fertilizer_to_water_part,
      "water-to-light map:\n" <> water_to_light_part,
      "light-to-temperature map:\n" <> light_to_temperature_part,
      "temperature-to-humidity map:\n" <> temperature_to_humidity_part,
      "humidity-to-location map:\n" <> humidity_to_location_part
    ] = parts

    %{
      seeds: str_nums_to_list(seeds_part),
      seed_to_soil: str_to_mapping(seed_to_soil_part),
      soil_to_fertilizer: str_to_mapping(soil_to_fertilizer_part),
      fertilizer_to_water: str_to_mapping(fertilizer_to_water_part),
      water_to_light: str_to_mapping(water_to_light_part),
      light_to_temperature: str_to_mapping(light_to_temperature_part),
      temperature_to_humidity: str_to_mapping(temperature_to_humidity_part),
      humidity_to_location: str_to_mapping(humidity_to_location_part)
    }
  end

  def find_matching_in_mapping(value, []), do: value

  def find_matching_in_mapping(value, mapping) do
    [h | rest] = mapping

    cond do
      h[:start] <= value and value < h[:start] + h[:range] ->
        delta = value - h[:start]

        h[:destination] + delta

      true ->
        find_matching_in_mapping(value, rest)
    end
  end

  def str_nums_to_list(str) do
    String.split(str, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def str_to_mapping(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.map(fn [dst, start, range] ->
      %{destination: dst, start: start, range: range}
    end)
  end
end
