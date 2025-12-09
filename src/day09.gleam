import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "input/day09"

pub type Coord {
  Coord(x: Int, y: Int)
}

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
  let assert Ok(tiles) = parse_input(lines)

  let p1 = part1(tiles)
  io.println("Part 1: " <> int.to_string(p1))
}

pub fn part1(tiles: List(Coord)) -> Int {
  largest_rectangle(tiles, 0)
}

pub fn parse_input(lines: List(String)) -> Result(List(Coord), Nil) {
  parse_input_recurse(lines, [])
}

fn parse_input_recurse(
  lines: List(String),
  acc: List(Coord),
) -> Result(List(Coord), Nil) {
  case lines {
    [] -> Ok(acc)
    [cur, ..rest] -> {
      use #(x_str, y_str) <- result.try(string.split_once(cur, ","))
      use x <- result.try(int.parse(x_str))
      use y <- result.try(int.parse(y_str))
      parse_input_recurse(rest, [Coord(x, y), ..acc])
    }
  }
}

fn largest_rectangle(tiles: List(Coord), largest: Int) -> Int {
  case tiles {
    [_just_one] | [] -> largest
    [cur, ..rest] -> {
      let assert Ok(largest_found) =
        rest
        |> list.map(fn(to_check) {
          { int.absolute_value(cur.x - to_check.x) + 1 }
          * { int.absolute_value(cur.y - to_check.y) + 1 }
        })
        |> list.max(int.compare)
      case largest_found > largest {
        True -> largest_rectangle(rest, largest_found)
        False -> largest_rectangle(rest, largest)
      }
    }
  }
}
