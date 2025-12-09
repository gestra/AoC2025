import day09.{parse_input, part1}
import gleam/string
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

const input_str = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

// gleeunit test functions end in `_test`
pub fn part1_test() {
  let lines =
    input_str
    |> string.split("\n")

  let assert Ok(tiles) = parse_input(lines)
  assert part1(tiles) == 50
}
