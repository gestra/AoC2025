import day02.{parse_input, part1, part2}
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

const input_str = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

// gleeunit test functions end in `_test`
pub fn part1_test() {
  let assert Ok(ranges) = parse_input(input_str)
  assert part1(ranges) == 1_227_775_554
}

pub fn part2_test() {
  let assert Ok(ranges) = parse_input(input_str)
  assert part2(ranges) == 4_174_379_265
}
// pub fn part2_test() {
//   let input =
//     input_str
//     |> string.split("\n")

//   let assert Ok(spins) = parse_input(input)
//   assert part2(spins) == 6
// }
