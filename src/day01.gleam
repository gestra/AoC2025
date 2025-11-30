import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "input/day01"

pub type Spin {
  Left(Int)
  Right(Int)
}

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
  let assert Ok(spins) = parse_input(lines)

  let p1 = part1(spins)
  io.println("Part 1: " <> int.to_string(p1))

  let p2 = part2(spins)
  io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(spins: List(Spin)) -> Int {
  positions_recurse(spins, [50])
  |> list.count(fn(x) { x == 0 })
}

pub fn part2(spins: List(Spin)) -> Int {
  count_zeros(spins, 50, 0)
}

pub fn parse_input(lines: List(String)) -> Result(List(Spin), Nil) {
  parse_recurse(lines, [])
}

fn parse_recurse(
  lines: List(String),
  acc: List(Spin),
) -> Result(List(Spin), Nil) {
  case lines {
    [] -> Ok(list.reverse(acc))
    [first, ..rest] -> {
      use dir <- result.try(string.first(first))
      use distance <- result.try(int.parse(string.drop_start(first, 1)))
      case dir {
        "L" -> parse_recurse(rest, [Left(distance), ..acc])
        "R" -> parse_recurse(rest, [Right(distance), ..acc])
        _ -> Error(Nil)
      }
    }
  }
}

fn positions_recurse(spins: List(Spin), acc: List(Int)) -> List(Int) {
  case spins {
    [] -> list.reverse(acc)
    [first, ..rest] -> {
      let assert Ok(cur) = list.first(acc)
      let next_pos = case first {
        Left(d) -> {
          let assert Ok(n) = int.modulo(cur - d, 100)
          n
        }
        Right(d) -> {
          let assert Ok(n) = int.modulo(cur + d, 100)
          n
        }
      }
      positions_recurse(rest, [next_pos, ..acc])
    }
  }
}

fn count_zeros(spins: List(Spin), prev_pos: Int, acc: Int) -> Int {
  case spins {
    [] -> acc
    [first, ..rest] -> {
      case first {
        Left(d) -> {
          let full_revolutions = d / 100
          let left_over = d - { full_revolutions * 100 }
          let assert Ok(new_pos) = int.modulo(prev_pos - left_over, 100)
          let passed_zero = prev_pos > 0 && prev_pos - left_over <= 0
          let zeros = case passed_zero {
            True -> full_revolutions + 1
            False -> full_revolutions
          }
          count_zeros(rest, new_pos, acc + zeros)
        }
        Right(d) -> {
          let full_revolutions = d / 100
          let left_over = d - { full_revolutions * 100 }
          let assert Ok(new_pos) = int.modulo(prev_pos + left_over, 100)
          let passed_zero = prev_pos + left_over >= 100
          let zeros = case passed_zero {
            True -> full_revolutions + 1
            False -> full_revolutions
          }
          count_zeros(rest, new_pos, acc + zeros)
        }
      }
    }
  }
}
