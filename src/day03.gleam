import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "input/day03"

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let assert Ok(banks) = parse_banks(input)

  let p1 = part1(banks)
  io.println("Part 1: " <> int.to_string(p1))

  let p2 = part2(banks)
  io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(banks: List(List(Int))) -> Int {
  banks
  |> list.map(fn(x) {
    let #(rest, _last) = list.split(x, list.length(x) - 1)
    let assert Ok(first_number) = list.max(rest, int.compare)
    let after_biggest_digit =
      list.drop_while(x, fn(x) { x != first_number })
      |> list.drop(1)
    let assert Ok(second_number) =
      after_biggest_digit
      |> list.max(int.compare)

    first_number * 10 + second_number
  })
  |> int.sum
}

pub fn part2(banks: List(List(Int))) -> Int {
  let assert Ok(numbers) =
    banks
    |> list.map(fn(x) { largest_joltage(x, 12) })
    |> list.map(fn(x) { list.take(x, 12) })
    |> list.map(fn(digits) {
      digits
      |> list.map(int.to_string)
      |> string.join("")
      |> int.parse
    })
    |> result.all

  numbers
  |> int.sum
}

pub fn parse_banks(input: String) -> Result(List(List(Int)), Nil) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.filter(fn(x) { x != "" })
  |> list.map(fn(x) {
    x
    |> string.to_graphemes
    |> list.map(int.parse)
    |> result.all
  })
  |> result.all
}

fn largest_joltage(bank: List(Int), digits: Int) -> List(Int) {
  let to_skip = list.length(bank) - digits
  joltage_recurse(bank, to_skip, [])
}

fn joltage_recurse(digits: List(Int), to_skip: Int, acc: List(Int)) -> List(Int) {
  case digits {
    [] -> list.reverse(acc)
    [first, ..rest] if to_skip == 0 -> {
      joltage_recurse(rest, to_skip, [first, ..acc])
    }
    [current, ..rest] -> {
      case list.first(acc) {
        Error(Nil) -> {
          joltage_recurse(rest, to_skip, [current, ..acc])
        }
        Ok(prev) if to_skip > 0 && prev < current -> {
          joltage_recurse(digits, to_skip - 1, list.drop(acc, 1))
        }
        Ok(_) -> {
          joltage_recurse(rest, to_skip, [current, ..acc])
        }
      }
    }
  }
}
