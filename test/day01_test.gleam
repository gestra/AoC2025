import day01.{parse_input, part1, part2}
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

const input_str = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"

// gleeunit test functions end in `_test`
pub fn part1_test() {
  let input =
    input_str
    |> string.split("\n")

  let assert Ok(spins) = parse_input(input)
  assert part1(spins) == 3
}

pub fn part2_test() {
  let input =
    input_str
    |> string.split("\n")

  let assert Ok(spins) = parse_input(input)
  assert part2(spins) == 6
}
