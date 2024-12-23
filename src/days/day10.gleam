import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 10!")

  // let filepath = "./src/days/day10.test"
  let filepath = "./src/days/day10.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let part_1_result = solve_part_1(text)

  // Part 1 result
  io.println("Part 1:")
  io.debug(part_1_result)

  let part_2_result = solve_part_2(text)

  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_result)
}

type Point {
  Point(x: Int, y: Int, value: Int)
}

type Map {
  Map(map: List(List(Point)), max_x: Int, max_y: Int)
}

fn solve_part_2(input: String) -> Int {
  let map = input |> make_map

  map
  |> get_trailheads
  |> list.map(fn(trailhead) { get_trailhead_rating(trailhead, map) })
  |> list.fold(0, fn(sum, score) { sum + score })
}

fn get_trailhead_rating(start: Point, map: Map) -> Int {
  get_peaks(start, map)
  |> list.filter(fn(point) { point.value == 9 })
  |> list.length
}

fn solve_part_1(input: String) -> Int {
  let map = input |> make_map

  map
  |> get_trailheads
  |> list.map(fn(trailhead) { get_trailhead_score(trailhead, map) })
  |> list.fold(0, fn(sum, score) { sum + score })
}

fn make_map(input: String) -> Map {
  let lines = string.split(input, "\n")
  let assert [line, ..] = lines

  let max_y = list.length(lines) - 1
  let max_x = string.length(line) - 1

  let map =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(point: String, x) {
        let assert Ok(num) = int.parse(point)
        Point(x, y, num)
      })
    })

  Map(map, max_x, max_y)
}

fn get_trailheads(map: Map) -> List(Point) {
  map.map
  |> list.map(fn(row) { row |> list.filter(fn(point) { point.value == 0 }) })
  |> list.flatten
}

fn get_trailhead_score(start: Point, map: Map) -> Int {
  get_peaks(start, map)
  |> list.filter(fn(point) { point.value == 9 })
  |> list.unique
  |> list.length
}

fn get_peaks(start: Point, map: Map) -> List(Point) {
  case start.value {
    9 -> [start]
    _ -> {
      let north = get_point(start.x, start.y - 1, map)
      let north_peaks = case north.value == start.value + 1 {
        True -> get_peaks(north, map)
        False -> []
      }

      let south = get_point(start.x, start.y + 1, map)
      let south_peaks = case south.value == start.value + 1 {
        True -> get_peaks(south, map)
        False -> []
      }

      let east = get_point(start.x + 1, start.y, map)
      let east_peaks = case east.value == start.value + 1 {
        True -> get_peaks(east, map)
        False -> []
      }

      let west = get_point(start.x - 1, start.y, map)
      let west_peaks = case west.value == start.value + 1 {
        True -> get_peaks(west, map)
        False -> []
      }

      list.flatten([north_peaks, south_peaks, east_peaks, west_peaks])
    }
  }
}

fn get_point(x: Int, y: Int, map: Map) -> Point {
  case x, y {
    a, b if a < 0 || a > map.max_x || b < 0 || b > map.max_y -> Point(0, 0, 0)
    _, _ -> {
      let #(_, bottom) = list.split(map.map, y)
      let assert [y_row, ..] = bottom

      let #(_, right) = list.split(y_row, x)
      let assert [point, ..] = right

      point
    }
  }
}
