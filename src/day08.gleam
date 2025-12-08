import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

const input_path = "input/day08"

pub type JunctionBox {
  JunctionBox(x: Int, y: Int, z: Int)
}

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
  let assert Ok(boxes) = parse_input(lines)

  let p1 = part1(boxes, 1000)
  io.println("Part 1: " <> int.to_string(p1))
  let p2 = part2(boxes)
  io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(boxes: List(JunctionBox), connections: Int) -> Int {
  pair_distances(boxes, dict.new())
  |> dict.to_list
  |> list.sort(fn(a, b) { float.compare(a.1, b.1) })
  |> list.take(connections)
  |> list.map(fn(x) { x.0 })
  |> connect_boxes(set.new())
  |> set.map(set.size)
  |> set.to_list
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(3)
  |> list.fold(1, fn(acc, x) { acc * x })
}

pub fn part2(boxes: List(JunctionBox)) -> Int {
  let num_of_boxes = list.length(boxes)
  let assert Ok(result) =
    pair_distances(boxes, dict.new())
    |> dict.to_list
    |> list.sort(fn(a, b) { float.compare(a.1, b.1) })
    |> list.map(fn(x) { x.0 })
    |> connect_boxes_until_all_connected(num_of_boxes, set.new())

  result
}

pub fn parse_input(lines: List(String)) -> Result(List(JunctionBox), Nil) {
  parse_input_recurse(lines, [])
}

fn parse_input_recurse(
  lines: List(String),
  acc: List(JunctionBox),
) -> Result(List(JunctionBox), Nil) {
  case lines {
    [] -> Ok(acc)
    [cur, ..rest] -> {
      use coords <- result.try(
        cur
        |> string.split(",")
        |> list.map(int.parse)
        |> result.all,
      )
      use x <- result.try(list.first(coords))
      use drop_first <- result.try(list.rest(coords))
      use y <- result.try(list.first(drop_first))
      use drop_second <- result.try(list.rest(drop_first))
      use z <- result.try(list.first(drop_second))

      parse_input_recurse(rest, [JunctionBox(x, y, z), ..acc])
    }
  }
}

fn pair_distances(
  boxes: List(JunctionBox),
  acc: dict.Dict(#(JunctionBox, JunctionBox), Float),
) -> dict.Dict(#(JunctionBox, JunctionBox), Float) {
  case boxes {
    [] -> acc
    [cur, ..rest] -> {
      let distances = distances_between(cur, rest)
      pair_distances(rest, dict.merge(acc, dict.from_list(distances)))
    }
  }
}

fn distances_between(
  this: JunctionBox,
  with_these: List(JunctionBox),
) -> List(#(#(JunctionBox, JunctionBox), Float)) {
  with_these
  |> list.map(fn(to_check) {
    let assert Ok(distance) =
      float.square_root({
        let assert Ok(a) =
          float.power(int.to_float(this.x) -. int.to_float(to_check.x), 2.0)
        let assert Ok(b) =
          float.power(int.to_float(this.y) -. int.to_float(to_check.y), 2.0)
        let assert Ok(c) =
          float.power(int.to_float(this.z) -. int.to_float(to_check.z), 2.0)
        a +. b +. c
      })

    #(#(this, to_check), distance)
  })
}

fn connect_boxes(
  boxes: List(#(JunctionBox, JunctionBox)),
  acc: set.Set(set.Set(JunctionBox)),
) -> set.Set(set.Set(JunctionBox)) {
  case boxes {
    [] -> acc
    [cur, ..rest] -> {
      let a = cur.0
      let b = cur.1
      let set_containing_a =
        set.filter(acc, fn(x) { set.contains(x, a) })
        |> set.to_list
        |> list.first
      let set_containing_b =
        set.filter(acc, fn(x) { set.contains(x, b) })
        |> set.to_list
        |> list.first

      case set_containing_a, set_containing_b {
        Error(_), Error(_) ->
          connect_boxes(rest, set.insert(acc, set.from_list([a, b])))
        Ok(set_a), Error(_) -> {
          let new_acc =
            acc
            |> set.drop([set_a])
            |> set.insert(set.insert(set_a, b))
          connect_boxes(rest, new_acc)
        }
        Error(_), Ok(set_b) -> {
          let new_acc =
            acc
            |> set.drop([set_b])
            |> set.insert(set.insert(set_b, a))
          connect_boxes(rest, new_acc)
        }
        Ok(set_a), Ok(set_b) -> {
          let new_acc =
            acc
            |> set.drop([set_a, set_b])
            |> set.insert(set.union(set_a, set_b))
          connect_boxes(rest, new_acc)
        }
      }
    }
  }
}

fn connect_boxes_until_all_connected(
  boxes: List(#(JunctionBox, JunctionBox)),
  num_of_boxes: Int,
  acc: set.Set(set.Set(JunctionBox)),
) -> Result(Int, Nil) {
  case boxes {
    [] -> Error(Nil)
    [cur, ..rest] -> {
      let a = cur.0
      let b = cur.1
      let set_containing_a =
        set.filter(acc, fn(x) { set.contains(x, a) })
        |> set.to_list
        |> list.first
      let set_containing_b =
        set.filter(acc, fn(x) { set.contains(x, b) })
        |> set.to_list
        |> list.first

      case set_containing_a, set_containing_b {
        Error(_), Error(_) ->
          connect_boxes_until_all_connected(
            rest,
            num_of_boxes,
            set.insert(acc, set.from_list([a, b])),
          )
        Ok(set_a), Error(_) -> {
          let new_set = set.insert(set_a, b)
          case set.size(new_set) == num_of_boxes {
            True -> Ok(a.x * b.x)
            False -> {
              let new_acc =
                acc
                |> set.drop([set_a])
                |> set.insert(new_set)
              connect_boxes_until_all_connected(rest, num_of_boxes, new_acc)
            }
          }
        }
        Error(_), Ok(set_b) -> {
          let new_set = set.insert(set_b, a)
          case set.size(new_set) == num_of_boxes {
            True -> Ok(a.x * b.x)
            False -> {
              let new_acc =
                acc
                |> set.drop([set_b])
                |> set.insert(new_set)
              connect_boxes_until_all_connected(rest, num_of_boxes, new_acc)
            }
          }
        }
        Ok(set_a), Ok(set_b) -> {
          let new_set = set.union(set_a, set_b)
          case set.size(new_set) == num_of_boxes {
            True -> Ok(a.x * b.x)
            False -> {
              let new_acc =
                acc
                |> set.drop([set_a, set_b])
                |> set.insert(new_set)
              connect_boxes_until_all_connected(rest, num_of_boxes, new_acc)
            }
          }
        }
      }
    }
  }
}
