import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "input/day05"

pub type Ingredients {
  Ingredients(fresh_ranges: List(#(Int, Int)), available: List(Int))
}

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
  let assert Ok(ingredients) = parse_input(lines)

  let p1 = part1(ingredients)
  io.println("Part 1: " <> int.to_string(p1))

  let p2 = part2(ingredients)
  io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(ingredients: Ingredients) -> Int {
  available_fresh(ingredients.available, ingredients.fresh_ranges, [])
  |> list.length
}

pub fn part2(ingredients: Ingredients) -> Int {
  let ordered =
    list.sort(ingredients.fresh_ranges, fn(l, r) { int.compare(l.0, r.0) })
  let non_overlapping = combine_overlapping(ordered, [])
  all_fresh(non_overlapping, 0)
}

pub fn parse_input(lines: List(String)) -> Result(Ingredients, Nil) {
  use #(ranges, available) <- result.try(parse_recurse(lines, True, [], []))
  Ok(Ingredients(fresh_ranges: ranges, available: available))
}

fn parse_recurse(
  lines: List(String),
  in_ranges: Bool,
  ranges_acc: List(#(Int, Int)),
  available_acc: List(Int),
) -> Result(#(List(#(Int, Int)), List(Int)), Nil) {
  case in_ranges {
    True ->
      case lines {
        [cur, ..rest] if cur != "" -> {
          use #(min_str, max_str) <- result.try(string.split_once(cur, "-"))
          use min <- result.try(int.parse(min_str))
          use max <- result.try(int.parse(max_str))
          parse_recurse(
            rest,
            in_ranges,
            [#(min, max), ..ranges_acc],
            available_acc,
          )
        }
        [cur, ..rest] if cur == "" ->
          parse_recurse(rest, False, ranges_acc, available_acc)
        _ -> Error(Nil)
      }
    False -> {
      case lines {
        [] -> Ok(#(ranges_acc, available_acc))
        [cur, ..rest] -> {
          use id <- result.try(int.parse(cur))
          parse_recurse(rest, in_ranges, ranges_acc, [id, ..available_acc])
        }
      }
    }
  }
}

fn available_fresh(
  available: List(Int),
  fresh_ranges: List(#(Int, Int)),
  acc: List(Int),
) -> List(Int) {
  case available {
    [] -> acc
    [cur, ..rest] -> {
      case is_fresh(cur, fresh_ranges) {
        True -> available_fresh(rest, fresh_ranges, [cur, ..acc])
        False -> available_fresh(rest, fresh_ranges, acc)
      }
    }
  }
}

fn is_fresh(id: Int, ranges: List(#(Int, Int))) -> Bool {
  case ranges {
    [] -> {
      False
    }
    [#(min, max), ..rest] -> {
      case id >= min && id <= max {
        True -> True
        False -> is_fresh(id, rest)
      }
    }
  }
}

fn all_fresh(non_overlapping_ranges: List(#(Int, Int)), acc: Int) -> Int {
  case non_overlapping_ranges {
    [] -> acc
    [#(min, max), ..rest] -> all_fresh(rest, acc + { max - min + 1 })
  }
}

fn combine_overlapping(
  ordered_ranges: List(#(Int, Int)),
  acc: List(#(Int, Int)),
) -> List(#(Int, Int)) {
  case ordered_ranges {
    [] -> list.reverse(acc)
    [only_one] -> list.reverse([only_one, ..acc])
    [first, second, ..rest] -> {
      case first.1 >= second.0 {
        True ->
          combine_overlapping(
            [#(first.0, int.max(first.1, second.1)), ..rest],
            acc,
          )
        False -> combine_overlapping([second, ..rest], [first, ..acc])
      }
    }
  }
}
