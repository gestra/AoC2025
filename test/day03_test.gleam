import day03.{parse_banks, part1, part2}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

const input_str = "987654321111111
811111111111119
234234234234278
818181911112111"

// gleeunit test functions end in `_test`
pub fn part1_test() {
  let assert Ok(banks) = parse_banks(input_str)
  assert part1(banks) == 357
}

pub fn part2_test() {
  let assert Ok(banks) = parse_banks(input_str)
  assert part2(banks) == 3_121_910_778_619
}
