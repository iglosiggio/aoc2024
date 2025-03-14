#let small(body) = context {
  text(size: text.size * 0.8, body)
}
#set page(
  paper: "a4",
  numbering: "1",
)
#set text(lang: "es")
#set par(justify: true)

#let enumerate(arr) = range(arr.len()).zip(arr)

#let log-id = counter("log-id")
#let dbg(..args) = {
  let named = args.named().pairs().map(((k, v)) => [#k = #v])
  let positional = args.pos().map(v => [#v])
  [[#log-id.display()] ]
  log-id.step()
  (named + positional).join(", ")
  linebreak()
}
#let code(body) = raw(lang: "typc", body)

#let globals = state("globals", (dbg: dbg, enumerate: enumerate))

#let label-options = (
  fill: gradient.linear(dir: ttb, luma(225), luma(245)),
  inset: 8pt,
  below: 0pt,
  radius: (top: 6pt),
)
#let body-options = (
  fill: luma(245),
  inset: 8pt,
  width: 100%,
  radius: (bottom: 6pt, top-right: 6pt),
)

#let reserve-below(amount: 6em, body) = {
  block(breakable: false, below: 0em, body + v(amount))
  v(-1 * amount)
}

#show raw.where(lang: "definition"): it => {
  log-id.update(0)
  reserve-below(block(..label-options, [*Code*]))
  block(..body-options, raw(lang: "typc", it.text))
  globals.update(currentGlobals => {
    (: ..currentGlobals, ..eval(scope: currentGlobals, it.text))
  })
}

#show raw.where(lang: "repl"): it => context {
  log-id.update(0)
  reserve-below(block(..label-options, [*Code*]))
  block(..body-options, raw(lang: "typc", it.text))
  reserve-below(block(..label-options, [*Result*]))
  block(..body-options, [#eval(scope: globals.get(), it.text)])
}

#show raw.where(lang: "data"): it => {
  raw(it.text)
  globals.update(currentGlobals => {
    let data = it.text
    let datas = currentGlobals.at("datas", default: ())
    (: ..currentGlobals, data: data, datas: (data, ..datas))
  })
}

#show heading: it => {
  if it.body == [Part One] or it.body == [Part Two] {
    globals.update(v => (: ..v, data: none, datas: ()))
  }
  it
}

= Helpers

Acá voy a ir agregando los helpers que me parezcan copados para que escribir
sea más sencillo.

```definition
let op = (
  // Arithmetic ops
  add: (a, b) => a + b,
  sub: (a, b) => a - b,
  mul: (a, b) => a * b,
  div: (a, b) => a / b,
  // Relational ops
  eq:  (a, b) => a == b,
  neq: (a, b) => a != b,
  gt:  (a, b) => a > b,
  gte: (a, b) => a >= b,
  lt:  (a, b) => a < b,
  lte: (a, b) => a <=b,
  // Boolean ops
  band: (a, b) => a and b,
  bor:  (a, b) => a or b,
  bnot: v => not v,
)

let at(i, ..args) = v => v.at(i, ..args)

let is_eq(a) = b => a == b
let is_neq(a) = b => a != b

let field(name) = eval("v => v." + name)
let call(name, ..args) = eval(
  "v => v." + name + "(..args)",
  scope: (args: args)
)


let unwrap(args) = arguments(..args)
let compose(start, ..fns) = (..args) => {
  let res = start(..args)
  for fn in fns.pos() {
    if type(res) == arguments {
      res = fn(..res)
    } else {
      res = fn(res)
    }
  }
  return res
}

(op: op,
 at: at,
 is_eq: is_eq,
 is_neq: is_neq,
 field: field,
 call: call,
 compose: compose,
 unwrap: unwrap)
```

= AOC 2024 (2da semana)

== Day 15: Warehouse Woes

=== Part One

You appear back inside your own mini submarine! Each Historian drives their
mini submarine in a different direction; maybe the Chief has his own submarine
down here somewhere as well?

You look up to see a vast school of lanternfish swimming past you. On closer
inspection, they seem quite anxious, so you drive your mini submarine over to
see if you can help.

Because lanternfish populations grow rapidly, they need a lot of food, and that
food needs to be stored somewhere. That's why these lanternfish have built
elaborate warehouse complexes operated by robots!

These lanternfish seem so anxious because they have lost control of the robot
that operates one of their most important warehouses! It is currently running
amok, pushing around boxes in the warehouse with no regard for lanternfish
logistics *or* lanternfish inventory management strategies.

Right now, none of the lanternfish are brave enough to swim up to an
unpredictable robot so they could shut it off. However, if you could anticipate
the robot's movements, maybe they could find a safe option.

The lanternfish already have a map of the warehouse and a list of movements the
robot will *attempt* to make (your puzzle input). The problem is that the
movements will sometimes fail as boxes are shifted around, making the actual
movements of the robot difficult to predict.

For example:

```data
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
```

As the robot (`@`) attempts to move, if there are any boxes (`O`) in the way,
the robot will also attempt to push those boxes. However, if this action would
cause the robot or a box to move into a wall (`#`), nothing moves instead,
including the robot. The initial positions of these are shown on the map at the
top of the document the lanternfish gave you.

The rest of the document describes the *moves* (`^` for up, `v` for down, `<`
for left, `>` for right) that the robot will attempt to make, in order. (The
moves form a single giant sequence; they are broken into multiple lines just to
make copy-pasting easier. Newlines within the move sequence should be ignored.)

Here is a smaller example to get started:

```data
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<
```

Were the robot to attempt the given sequence of moves, it would push around the
boxes as follows:

```
Initial state:
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move <:
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move ^:
########
#.@O.O.#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move ^:
########
#.@O.O.#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move >:
########
#..@OO.#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move >:
########
#...@OO#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move >:
########
#...@OO#
##..O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

Move v:
########
#....OO#
##..@..#
#...O..#
#.#.O..#
#...O..#
#...O..#
########

Move v:
########
#....OO#
##..@..#
#...O..#
#.#.O..#
#...O..#
#...O..#
########

Move <:
########
#....OO#
##.@...#
#...O..#
#.#.O..#
#...O..#
#...O..#
########

Move v:
########
#....OO#
##.....#
#..@O..#
#.#.O..#
#...O..#
#...O..#
########

Move >:
########
#....OO#
##.....#
#...@O.#
#.#.O..#
#...O..#
#...O..#
########

Move >:
########
#....OO#
##.....#
#....@O#
#.#.O..#
#...O..#
#...O..#
########

Move v:
########
#....OO#
##.....#
#.....O#
#.#.O@.#
#...O..#
#...O..#
########

Move <:
########
#....OO#
##.....#
#.....O#
#.#O@..#
#...O..#
#...O..#
########

Move <:
########
#....OO#
##.....#
#.....O#
#.#O@..#
#...O..#
#...O..#
########
```

The larger example has many more moves; after the robot has finished those
moves, the warehouse would look like this:

```
##########
#.O.O.OOO#
#........#
#OO......#
#OO@.....#
#O#.....O#
#O.....OO#
#O.....OO#
#OO....OO#
##########
```

The lanternfish use their own custom Goods Positioning System (GPS for short)
to track the locations of the boxes. The *GPS coordinate* of a box is equal to
100 times its distance from the top edge of the map plus its distance from the
left edge of the map. (This process does not stop at wall tiles; measure all
the way to the edges of the map.)

So, the box shown below has a distance of `1` from the top edge of the map and
`4` from the left edge of the map, resulting in a GPS coordinate of
`100 * 1 + 4 = 104`.

```
#######
#...O..
#......
```

The lanternfish would like to know the *sum of all boxes' GPS coordinates*
after the robot finishes moving. In the larger example, the sum of all boxes'
GPS coordinates is *`10092`*. In the smaller example, the sum is *`2028`*.

Predict the motion of the robot and boxes in the warehouse. After the robot is
finished moving, *what is the sum of all boxes' GPS coordinates?*

==== Resolución

Debería alcanzar con simular.

```repl
let parse(data) = {
  let (map, moves) = data.split("\n\n")
  map = map.split("\n").map(call("codepoints"))
  moves = moves.replace("\n", "")
  (map, moves)
}

let is-inside(map, (x, y)) = {
  if 0 <= y and y < map.len() {
    return 0 <= x and x < map.first().len()
  }
  return false
}

let move(map, (x, y), (dx, dy)) = {
  assert(map.at(y).at(x) == "@")
  let c = "@"
  let (cx, cy) = (x + dx, y + dy)
  while true {
    assert(is-inside(map, (cx, cy)))
    c = map.at(cy).at(cx)
    if c == "#" { break }
    if c == "." { break }
    assert(c == "O", message: "Expected an O but got " + c)
    cx = cx + dx
    cy = cy + dy
  }
  if c == "#" {
    return (false, (x, y), map)
  } else if c == "." {
    map.at(cy).at(cx) = map.at(cy - dy).at(cx - dx)
    map.at(y).at(x) = "."
    map.at(y + dy).at(x + dx) = "@"
    map.at(y).at(x) = "."
    return (true, (x + dx, y + dy), map)
  }
  // Should never happen
  assert(false)
}

let start(map) = {
  for (y, row) in map.enumerate() {
    for (x, c) in row.enumerate() {
      if c == "@" { return (x, y) }
    }
  }
  assert(false)
}

let draw-map(map) = box(raw(map.map(call("join")).join("\n")))

let dir = (
  "^": ( 0, -1),
  ">": ( 1,  0),
  "v": ( 0,  1),
  "<": (-1, 0),
)

let run-simulation(data, debug: false) = {
  let (map, moves) = parse(data)
  let p = start(map)
  assert(is-inside(map, p))
  dbg(p: p, draw-map(map))
  for c in moves {
    let worked
    (worked, p, map) = move(map, p, dir.at(c))
    if debug {
      dbg(move: c, worked: worked, draw-map(map))
    }
  }
  if not debug {
    return map
  }
}

let hash(map) = {
  let result = 0
  for (y, row) in map.enumerate() {
    for (x, c) in row.enumerate() {
      if c == "O" {
        result = result + y * 100 + x
      }
    }
  }
  return result
}

run-simulation(data, debug: true)

let map-small-example = run-simulation(data)
let map-big-example = run-simulation(datas.at(1))
dbg(answer: hash(map-small-example), map: draw-map(map-small-example))
dbg(answer: hash(map-big-example), map: draw-map(map-big-example))

let map-input = run-simulation(read("2024-12-15.data"))
dbg(answer: hash(map-input), map: draw-map(map-input))
```
