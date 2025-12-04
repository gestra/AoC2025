import day04.{parse_input, part1, part2}
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

const input_str = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

// gleeunit test functions end in `_test`
pub fn part1_test() {
  let input =
    input_str
    |> string.split("\n")

  let warehouse = parse_input(input)
  assert part1(warehouse) == 13
}

pub fn part2_test() {
  let input =
    input_str
    |> string.split("\n")

  let warehouse = parse_input(input)
  assert part2(warehouse) == 43
}
