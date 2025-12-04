import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const input_path = "input/day04"

pub type Warehouse =
  dict.Dict(#(Int, Int), Bool)

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
    |> list.filter(fn(x) { x != "" })
  let warehouse = parse_input(lines)

  let p1 = part1(warehouse)
  io.println("Part 1: " <> int.to_string(p1))

  let p2 = part2(warehouse)
  io.println("Part 2: " <> int.to_string(p2))
}

pub fn part1(warehouse: Warehouse) -> Int {
  warehouse
  |> dict.keys
  |> list.map(fn(x) {
    case dict.get(warehouse, x) {
      Ok(True) -> is_accessible(x, warehouse)
      _ -> False
    }
  })
  |> list.count(fn(x) { x })
}

pub fn part2(warehouse: Warehouse) -> Int {
  let original_size = dict.size(warehouse)
  let new = remove_accessible_recurse(warehouse)
  original_size - dict.size(new)
}

pub fn parse_input(lines: List(String)) -> Warehouse {
  parse_recurse(lines, 0, dict.new())
}

fn parse_recurse(lines: List(String), row: Int, acc: Warehouse) -> Warehouse {
  case lines {
    [] -> acc
    [line, ..rest] -> {
      let new_warehouse = parse_line(line, row, 0, acc)
      parse_recurse(rest, row + 1, new_warehouse)
    }
  }
}

fn parse_line(line: String, row: Int, col: Int, acc: Warehouse) -> Warehouse {
  case string.pop_grapheme(line) {
    Error(_) -> acc
    Ok(#("@", rest)) ->
      parse_line(rest, row, col + 1, dict.insert(acc, #(row, col), True))
    Ok(#(_, rest)) -> parse_line(rest, row, col + 1, acc)
  }
}

fn is_accessible(coord: #(Int, Int), warehouse: Warehouse) -> Bool {
  let #(x, y) = coord
  let adjacent_positions = [
    #(x - 1, y - 1),
    #(x - 1, y),
    #(x - 1, y + 1),
    #(x, y - 1),
    #(x, y + 1),
    #(x + 1, y - 1),
    #(x + 1, y),
    #(x + 1, y + 1),
  ]

  adjacent_positions
  |> list.map(fn(x) { dict.get(warehouse, x) })
  |> list.map(fn(x) {
    case x {
      Ok(True) -> True
      _ -> False
    }
  })
  |> list.count(fn(x) { x })
  < 4
}

fn remove_accessible_recurse(warehouse: Warehouse) -> Warehouse {
  let prev_size = dict.size(warehouse)
  let new = remove_accessible(warehouse)
  let new_size = dict.size(new)
  case new_size == prev_size {
    True -> new
    False -> remove_accessible_recurse(new)
  }
}

fn remove_accessible(warehouse: Warehouse) -> Warehouse {
  let accessible =
    warehouse
    |> dict.keys
    |> list.filter(fn(x) { is_accessible(x, warehouse) })

  dict.drop(warehouse, accessible)
}
