import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "input/day07"

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
  let #(start, splitters) = parse_input(lines)

  let p1 = part1(start, splitters)
  io.println("Part 1: " <> int.to_string(p1))

  let p2 = part2(start, splitters)
  io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(start: Int, splitters: List(List(Int))) -> Int {
  part1_recurse(splitters, [start], 0)
}

pub fn part2(start: Int, splitters: List(List(Int))) -> Int {
  let #(res, _) = part2_recurse(splitters, start, dict.new())

  res
}

fn part1_recurse(
  splitters: List(List(Int)),
  beams: List(Int),
  splits: Int,
) -> Int {
  case splitters {
    [] -> splits
    [cur, ..rest] -> {
      let #(new_beams, new_splits) =
        beams
        |> list.fold(#([], 0), fn(acc, x) {
          case list.contains(cur, x) {
            True -> #([x - 1, x + 1, ..acc.0], acc.1 + 1)
            False -> #([x, ..acc.0], acc.1)
          }
        })

      part1_recurse(rest, list.unique(new_beams), splits + new_splits)
    }
  }
}

type MemoizeCache =
  dict.Dict(#(Int, Int), Int)

fn part2_recurse(
  splitters: List(List(Int)),
  beam: Int,
  memoize_cache: MemoizeCache,
) -> #(Int, MemoizeCache) {
  case splitters {
    [] -> #(1, memoize_cache)
    [cur, ..rest] -> {
      case list.find(cur, fn(x) { x == beam }) {
        Ok(_) -> {
          let #(left, new_cache) = case
            dict.get(memoize_cache, #(list.length(rest), beam - 1))
          {
            Ok(v) -> #(v, memoize_cache)
            Error(_) -> {
              let #(res, returned_cache) =
                part2_recurse(rest, beam - 1, memoize_cache)
              #(
                res,
                dict.insert(returned_cache, #(list.length(rest), beam - 1), res),
              )
            }
          }

          let #(right, new_cache) = case
            dict.get(memoize_cache, #(list.length(rest), beam + 1))
          {
            Ok(v) -> #(v, memoize_cache)
            Error(_) -> {
              let #(res, returned_cache) =
                part2_recurse(rest, beam + 1, new_cache)
              #(
                res,
                dict.insert(returned_cache, #(list.length(rest), beam + 1), res),
              )
            }
          }

          #(left + right, new_cache)
        }
        Error(_) -> {
          let #(res, new_cache) = case
            dict.get(memoize_cache, #(list.length(rest), beam))
          {
            Ok(v) -> #(v, memoize_cache)
            Error(_) -> {
              let #(res, returned_cache) =
                part2_recurse(rest, beam, memoize_cache)
              #(
                res,
                dict.insert(returned_cache, #(list.length(rest), beam), res),
              )
            }
          }

          #(res, new_cache)
        }
      }
    }
  }
}

pub fn parse_input(lines: List(String)) -> #(Int, List(List(Int))) {
  let assert Ok(start_line) = list.first(lines)
  let start =
    start_line
    |> string.to_graphemes
    |> list.fold_until(0, fn(acc, x) {
      case x == "S" {
        True -> list.Stop(acc)
        False -> list.Continue(acc + 1)
      }
    })

  let assert Ok(rest) = list.rest(lines)

  #(start, parse_recurse(rest, []))
}

fn parse_recurse(lines: List(String), acc: List(List(Int))) -> List(List(Int)) {
  case lines {
    [] -> list.reverse(acc)
    [current, ..rest] -> {
      let splitters =
        current
        |> string.to_graphemes
        |> list.index_fold([], fn(acc, x, i) {
          case x == "^" {
            True -> [i, ..acc]
            False -> acc
          }
        })

      parse_recurse(rest, [splitters, ..acc])
    }
  }
}
