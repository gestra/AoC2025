import gleam/deque
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

const input_path = "input/day10"

pub type Machine {
  Machine(lights: Int, buttons: List(Int), joltages: List(Int))
}

pub fn main() {
  let assert Ok(input) = simplifile.read(input_path)
  let lines =
    input
    |> string.trim
    |> string.split("\n")
  let machines = parse_input(lines)

  let p1 = part1(machines)
  io.println("Part 1: " <> int.to_string(p1))
}

pub fn part1(machines: List(Machine)) -> Int {
  machines
  |> list.map(fn(machine) {
    let queue =
      machine.buttons
      |> list.fold(deque.new(), fn(acc, button) {
        deque.push_back(acc, Vertex(state: 0, to_press: button, parents: []))
      })
    fewest_bfs(machine.lights, machine.buttons, queue, set.new())
  })
  |> int.sum
}

type Vertex {
  Vertex(state: Int, to_press: Int, parents: List(Int))
}

fn fewest_bfs(
  goal: Int,
  buttons: List(Int),
  queue: deque.Deque(Vertex),
  seen: set.Set(#(Int, Int)),
) -> Int {
  let assert Ok(#(v, queue_rest)) = deque.pop_front(queue)
  case set.contains(seen, #(v.state, v.to_press)) {
    True -> fewest_bfs(goal, buttons, queue_rest, seen)
    False -> {
      let after_pressing = int.bitwise_exclusive_or(v.state, v.to_press)
      case after_pressing == goal {
        True -> list.length(v.parents) + 1
        False -> {
          let new_queue =
            buttons
            |> list.fold(queue_rest, fn(acc, x) {
              deque.push_back(
                acc,
                Vertex(state: after_pressing, to_press: x, parents: [
                  after_pressing,
                  ..v.parents
                ]),
              )
            })
          fewest_bfs(
            goal,
            buttons,
            new_queue,
            set.insert(seen, #(v.state, v.to_press)),
          )
        }
      }
    }
  }
}

pub fn parse_input(lines: List(String)) -> List(Machine) {
  lines
  |> list.map(fn(line) {
    let sections = string.split(line, " ")
    let assert Ok(light_pattern_section) = list.first(sections)
    let buttons_sections =
      {
        let assert Ok(rest) = sections |> list.rest
        rest
      }
      |> list.take(list.length(sections) - 2)
    let assert Ok(joltages_section) = list.last(sections)

    let light_pattern_trimmed =
      light_pattern_section |> string.drop_start(1) |> string.drop_end(1)
    let light_pattern =
      light_pattern_trimmed
      |> string.to_graphemes()
      |> list.reverse
      |> list.fold(0, fn(acc, x) {
        case x {
          "#" -> int.bitwise_shift_left(acc, 1) + 1
          "." -> int.bitwise_shift_left(acc, 1)
          _ -> panic as "Light pattern should be # or ."
        }
      })

    let buttons =
      buttons_sections
      |> list.map(fn(x) {
        x
        |> string.drop_start(1)
        |> string.drop_end(1)
        |> string.split(",")
        |> list.map(fn(y) {
          let assert Ok(i) = int.parse(y)
          i
        })
        |> list.fold(0, fn(acc, x) { acc + int.bitwise_shift_left(1, x) })
      })

    let joltages =
      joltages_section
      |> string.drop_start(1)
      |> string.drop_end(1)
      |> string.split(",")
      |> list.map(fn(x) {
        let assert Ok(i) = int.parse(x)
        i
      })

    Machine(lights: light_pattern, buttons: buttons, joltages: joltages)
  })
}
