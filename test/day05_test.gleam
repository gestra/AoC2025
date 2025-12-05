import day05.{parse_input, part1, part2}
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

const input_str = "3-5
10-14
16-20
12-18

1
5
8
11
17
32"

// gleeunit test functions end in `_test`
pub fn part1_test() {
  let input =
    input_str
    |> string.split("\n")

  let assert Ok(parsed) = parse_input(input)
  assert part1(parsed) == 3
}

pub fn part2_test() {
  let input =
    input_str
    |> string.split("\n")

  let assert Ok(parsed) = parse_input(input)
  assert part2(parsed) == 14
}
