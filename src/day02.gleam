import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "input/day02"

pub type Range {
  Range(min: Int, max: Int)
}

pub fn main() {
  let assert Ok(input_str) = simplifile.read(input_path)
  let input =
    input_str
    |> string.trim
  let assert Ok(ranges) = parse_input(input)

  let p1 = part1(ranges)
  io.println("Part 1: " <> int.to_string(p1))
  let p2 = part2(ranges)
  io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(ranges: List(Range)) -> Int {
  ranges
  |> list.map(fn(x) {
    invalid_ids_from_range(x, x.min, [], sequence_repeats_twice)
  })
  |> list.flatten
  |> list.fold(0, int.add)
}

pub fn part2(ranges: List(Range)) -> Int {
  ranges
  |> list.map(fn(x) {
    invalid_ids_from_range(x, x.min, [], has_repeating_sequence)
  })
  |> list.flatten
  |> list.fold(0, int.add)
}

pub fn parse_input(input: String) -> Result(List(Range), Nil) {
  input
  |> string.split(",")
  |> list.map(fn(x) { string.split_once(x, "-") })
  |> list.map(fn(x) {
    use #(min_s, max_s) <- result.try(x)
    use min <- result.try(int.parse(min_s))
    use max <- result.try(int.parse(max_s))
    Ok(Range(min, max))
  })
  |> result.all
}

fn invalid_ids_from_range(
  range: Range,
  current: Int,
  acc: List(Int),
  invalid_check: fn(Int) -> Bool,
) -> List(Int) {
  case current {
    a if a >= range.min && a <= range.max -> {
      case invalid_check(a) {
        False -> invalid_ids_from_range(range, current + 1, acc, invalid_check)
        True ->
          invalid_ids_from_range(range, current + 1, [a, ..acc], invalid_check)
      }
    }
    _ -> acc
  }
}

fn sequence_repeats_twice(id: Int) -> Bool {
  let str = int.to_string(id)
  let sequence = string.drop_end(str, string.length(str) / 2)

  string.length(str) % 2 == 0
  && string.starts_with(str, sequence)
  && string.ends_with(str, sequence)
}

fn has_repeating_sequence(id: Int) -> Bool {
  let str = int.to_string(id)
  has_repeating_sequence_recurse(str, 1)
}

fn has_repeating_sequence_recurse(id: String, len: Int) -> Bool {
  case len > string.length(id) / 2 {
    True -> False
    False -> {
      case string.length(id) % len != 0 {
        True -> has_repeating_sequence_recurse(id, len + 1)
        False -> {
          let sequence = string.drop_end(id, string.length(id) - len)
          case sequence_repeats(id, sequence, 2) {
            True -> True
            False -> has_repeating_sequence_recurse(id, len + 1)
          }
        }
      }
    }
  }
}

fn sequence_repeats(id: String, seq: String, times: Int) -> Bool {
  case string.length(seq) * times > string.length(id) {
    True -> False
    False -> {
      case string.repeat(seq, times) == id {
        True -> True
        False -> sequence_repeats(id, seq, times + 1)
      }
    }
  }
}
