import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

const input_path = "input/day06"

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
  let assert Ok(#(number_lines, operator_line)) = parse(lines)
  let p1 = part1(number_lines, operator_line)
  io.println("Part 1: " <> int.to_string(p1))
  // let p2 = part2(spins)
  // io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(number_lines: List(List(Int)), operator_line: List(String)) -> Int {
  solve_problems(number_lines, operator_line, [])
}

// pub fn part2() -> Int {
//   todo
// }

pub fn parse(
  lines: List(String),
) -> Result(#(List(List(Int)), List(String)), Nil) {
  let #(number_lines, operator_lines) =
    lines
    |> list.split(list.length(lines) - 1)

  use operator_line <- result.try(list.first(operator_lines))
  let operators =
    operator_line
    |> string.split(" ")
    |> list.filter(fn(s) { s != "" })
    |> list.map(string.trim)

  use numbers <- result.try(
    number_lines
    |> list.map(fn(x) {
      x
      |> string.split(" ")
      |> list.filter(fn(s) { s != "" })
      |> list.map(fn(y) {
        y
        |> string.trim
        |> int.parse
      })
      |> result.all
    })
    |> result.all,
  )

  Ok(#(numbers, operators))
}

fn solve_problems(
  number_lines: List(List(Int)),
  operator_line: List(String),
  solutions: List(Int),
) -> Int {
  let first_numbers =
    number_lines
    |> list.map(list.first)
    |> result.all

  case first_numbers {
    Error(Nil) -> int.sum(solutions)
    Ok(ns) -> {
      let assert Ok(operator) = list.first(operator_line)
      let assert Ok(solution) = case operator {
        "+" -> Ok(int.sum(ns))
        "*" -> Ok(list.fold(ns, 1, int.multiply))
        _ -> Error(Nil)
      }

      solve_problems(
        list.map(number_lines, fn(x) { list.drop(x, 1) }),
        list.drop(operator_line, 1),
        [solution, ..solutions],
      )
    }
  }
}
