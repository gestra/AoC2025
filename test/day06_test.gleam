import day06.{parse, part1, part2}
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

const input_str = "123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +"

// gleeunit test functions end in `_test`
pub fn part1_test() {
  let lines =
    input_str
    |> string.split("\n")

  let assert Ok(#(number_lines, operator_line)) = parse(lines)
  assert part1(number_lines, operator_line) == 4_277_556
}

pub fn part2_test() {
  let input =
    input_str
    |> string.split("\n")
  // let assert Ok(spins) = parse_input(input)
  // assert part2(spins) == 6
  assert False
}
