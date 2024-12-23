import gleam/dict
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 8!")

  // let filepath = "./src/days/day8.test"
  let filepath = "./src/days/day8.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let part_1_result = count_unique_antinodes_in_map(text)

  // Part 1 result
  io.println("Part 1:")
  io.debug(part_1_result)

  let part_2_result = count_unique_harmonic_antinodes_in_map(text)

  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_result)
}

type Node {
  Node(x: Int, y: Int, antenna: String)
}

fn count_unique_harmonic_antinodes_in_map(map: String) {
  get_all_harmonic_antinodes(map)
  |> list.map(fn(node) { #(node.x, node.y) })
  |> list.unique
  |> list.length
}

fn get_all_harmonic_antinodes(map: String) -> List(Node) {
  get_antennas(map)
  |> list.map(fn(nodes) { get_harmonic_antinodes(nodes, map) })
  |> list.flatten
}

fn get_harmonic_antinodes(
  nodes: #(String, List(Node)),
  map: String,
) -> List(Node) {
  let #(_, node_list) = nodes

  node_list
  |> list.combinations(2)
  |> list.map(fn(node_pair) {
    let assert [first, second] = node_pair
    // let harmonics =
    [get_harmonics(first, second, map), get_harmonics(second, first, map)]
    |> list.flatten
    // io.debug(harmonics)
  })
  |> list.flatten
}

fn get_harmonics(from: Node, to: Node, map: String) -> List(Node) {
  let next_node = Node(2 * to.x - from.x, 2 * to.y - from.y, from.antenna)

  case node_in_map_bounds(next_node, map) {
    True -> [to, ..get_harmonics(to, next_node, map)]
    False -> [to]
  }
}

fn count_unique_antinodes_in_map(map: String) {
  get_all_antinodes(map)
  |> list.filter(fn(node) { node_in_map_bounds(node, map) })
  |> list.map(fn(node) { #(node.x, node.y) })
  |> list.unique
  |> list.length
}

fn node_in_map_bounds(node: Node, map: String) -> Bool {
  let #(max_x, max_y) = get_map_size(map)
  node.x >= 0 && node.x <= max_x && node.y >= 0 && node.y <= max_y
}

fn get_all_antinodes(map: String) -> List(Node) {
  get_antennas(map)
  |> list.map(get_antinodes)
  |> list.flatten
  |> list.unique
}

fn get_antinodes(nodes: #(String, List(Node))) -> List(Node) {
  let #(_, node_list) = nodes

  node_list
  |> list.combinations(2)
  |> list.map(fn(node_pair) {
    let assert [first, second] = node_pair
    [
      Node(2 * first.x - second.x, 2 * first.y - second.y, first.antenna),
      Node(2 * second.x - first.x, 2 * second.y - first.y, second.antenna),
    ]
  })
  |> list.flatten
}

fn get_antennas(map: String) -> List(#(String, List(Node))) {
  map
  |> string.split("\n")
  |> list.index_map(fn(line, y) {
    string.to_graphemes(line)
    |> list.index_map(fn(c, x) { Node(x, y, c) })
  })
  |> list.flatten
  |> list.group(fn(node) { node.antenna })
  |> dict.delete(".")
  |> dict.filter(fn(_key, value) { list.length(value) > 1 })
  |> dict.to_list
}

fn get_map_size(map) -> #(Int, Int) {
  let lines = map |> string.split("\n")
  let assert Ok(line) = list.first(lines)

  #(string.length(line) - 1, list.length(lines) - 1)
}
