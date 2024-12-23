import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from day 9!")

  // let filepath = "./src/days/day9.test"
  let filepath = "./src/days/day9.input"

  let assert Ok(text) = simplifile.read(from: filepath)

  let part_1_result =
    text
    |> get_blocks(True, 0)
    |> compact_blocks
    |> get_checksum

  // Part 1 result
  io.println("Part 1:")
  io.debug(part_1_result)

  let part_2_result =
    text
    |> get_blocks_with_size(True, 0)
    |> list.reverse
    |> compact_reversed_blocks
    |> list.reverse
    |> block_spread
    |> get_checksum_blocks

  // Part 2 result
  io.println("Part 2:")
  io.debug(part_2_result)
}

type File {
  File(id: Int)
  Free
}

pub type Block {
  FileSize(size: Int, id: Int)
  FreeSize(size: Int)
}

fn get_blocks_with_size(input: String, file: Bool, index: Int) -> List(Block) {
  let assert Ok(#(first, rest)) = string.pop_grapheme(input)

  let block = get_block_with_size(first, file, index)
  let index = case file {
    True -> index + 1
    False -> index
  }

  case rest {
    "" -> [block]
    _ -> [block, ..get_blocks_with_size(rest, !file, index)]
  }
}

fn get_block_with_size(times: String, file: Bool, index: Int) -> Block {
  let assert Ok(times_num) = int.parse(times)

  case file {
    True -> FileSize(times_num, index)
    False -> FreeSize(times_num)
  }
}

fn compact_reversed_blocks(blocks: List(Block)) -> List(Block) {
  let assert [last, ..rest] = blocks
  case last, rest {
    _, [] -> [last]
    FreeSize(x), _ -> {
      let assert [first, ..remaining] = rest

      case first {
        FreeSize(y) -> [FreeSize(x + y), ..compact_reversed_blocks(remaining)]
        _ -> [last, ..compact_reversed_blocks(rest)]
      }
    }
    _, _ -> {
      let #(last, rest) = compact_block(last, rest)
      [last, ..compact_reversed_blocks(rest)]
    }
  }
}

fn compact_block(
  block_to_compact: Block,
  blocks: List(Block),
) -> #(Block, List(Block)) {
  let #(left, right) =
    blocks
    |> list.reverse
    |> list.split_while(fn(block) {
      case block {
        FreeSize(x) if x >= block_to_compact.size -> False
        _ -> True
      }
    })

  // io.debug(right)

  case right {
    [] -> #(block_to_compact, blocks)
    _ -> {
      let assert [free, ..rest] = right

      let snug = free.size == block_to_compact.size

      let graft = case snug {
        True -> [block_to_compact]
        False -> [block_to_compact, FreeSize(free.size - block_to_compact.size)]
      }

      let blocks = list.flatten([left, graft, rest]) |> list.reverse
      // io.debug(blocks)
      #(FreeSize(block_to_compact.size), blocks)
    }
  }
}

fn block_spread(blocks: List(Block)) -> List(Block) {
  case blocks {
    [FreeSize(x)] -> list.repeat(FreeSize(x), x)
    [FileSize(x, id)] -> list.repeat(FileSize(x, id), x)
    [x, ..rest] -> list.flatten([block_spread([x]), block_spread(rest)])
    [] -> panic
  }
}

fn get_checksum_blocks(blocks: List(Block)) -> Int {
  blocks
  |> list.index_fold(0, fn(sum, value, index) {
    case value {
      FreeSize(_) -> sum
      FileSize(_, id) -> sum + id * index
    }
  })
}

fn get_blocks(input: String, file: Bool, index: Int) -> List(File) {
  let assert Ok(#(first, rest)) = string.pop_grapheme(input)

  let block = get_block(first, file, index)
  let index = case file {
    True -> index + 1
    False -> index
  }

  case rest {
    "" -> block
    _ -> list.flatten([block, get_blocks(rest, !file, index)])
  }
}

fn get_block(times: String, file: Bool, index: Int) -> List(File) {
  let assert Ok(times_num) = int.parse(times)

  case file {
    True -> list.repeat(File(index), times_num)
    False -> list.repeat(Free, times_num)
  }
}

fn compact_blocks(blocks: List(File)) -> List(File) {
  let spaces =
    blocks
    |> list.filter(fn(c) { c == Free })
    |> list.length

  let #(left, right) = list.split(blocks, list.length(blocks) - spaces)

  compact(left, right)
}

fn compact(left: List(File), right: List(File)) -> List(File) {
  let assert [first, ..rest] = left

  case first, rest {
    Free, _ -> {
      let #(next, right) = get_next_right(right)
      [next, ..compact(rest, right)]
    }
    _, [] -> [first]
    _, _ -> [first, ..compact(rest, right)]
  }
}

fn get_next_right(right: List(File)) -> #(File, List(File)) {
  let assert Ok(#(next, rest)) = list.pop(list.reverse(right), fn(_) { True })

  case next {
    Free -> get_next_right(list.reverse(rest))
    _ -> #(next, list.reverse(rest))
  }
}

fn get_checksum(blocks: List(File)) -> Int {
  blocks
  |> list.index_fold(0, fn(sum, value, index) {
    case value {
      Free -> sum
      File(id) -> sum + id * index
    }
  })
}
