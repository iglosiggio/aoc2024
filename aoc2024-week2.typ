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

== Day 8: Resonant Collinearity

=== Part One

You find yourselves on the roof of a top-secret Easter Bunny installation.

While The Historians do their thing, you take a look at the familiar *huge
antenna*. Much to your surprise, it seems to have been reconfigured to emit a
signal that makes people 0.1% more likely to buy Easter Bunny brand Imitation
Mediocre Chocolate as a Christmas gift! Unthinkable!

Scanning across the city, you find that there are actually many such antennas.
Each antenna is tuned to a specific *frequency* indicated by a single lowercase
letter, uppercase letter, or digit. You create a map (your puzzle input) of
these antennas. For example:

```data
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
```

The signal only applies its nefarious effect at specific *antinodes* based on
the resonant frequencies of the antennas. In particular, an antinode occurs at
any point that is perfectly in line with two antennas of the same frequency -
but only when one of the antennas is twice as far away as the other. This means
that for any pair of antennas with the same frequency, there are two antinodes,
one on either side of them.

So, for these two antennas with frequency a, they create the two antinodes
marked with `#`:

```
..........
...#......
..........
....a.....
..........
.....a....
..........
......#...
..........
..........
```

Adding a third antenna with the same frequency creates several more antinodes.
It would ideally add four antinodes, but two are off the right side of the map,
so instead it adds only two:

```
..........
...#......
#.........
....a.....
........a.
.....a....
..#.......
......#...
..........
..........
```

Antennas with different frequencies don't create antinodes; `A` and `a` count
as different frequencies. However, antinodes *can* occur at locations that
contain antennas. In this diagram, the lone antenna with frequency capital `A`
creates no antinodes but has a lowercase-`a`-frequency antinode at its
location:

```
..........
...#......
#.........
....a.....
........a.
.....a....
..#.......
......A...
..........
..........
```

The first example has antennas with two different frequencies, so the antinodes
they create look like this, plus an antinode overlapping the topmost
`A`-frequency antenna:

```
......#....#
...#....0...
....#0....#.
..#....0....
....0....#..
.#....A.....
...#........
#......#....
........A...
.........A..
..........#.
..........#.
```

Because the topmost `A`-frequency antenna overlaps with a `0`-frequency
antinode, there are `14` total unique locations that contain an antinode within
the bounds of the map.

Calculate the impact of the signal. *How many unique locations within the
bounds of the map contain an antinode?*

==== Resolución

Uh, es medio un bajón la explicación. Creo que con agarrar cada par de antenas
del mismo tipo y calcular los posibles puntos de los antinodos debería
alcanzar.

```definition
let parse(data) = (
  data
    .split("\n")
    .filter(is_neq("")))

let antennas(data) = {
  let result = (:)
  for (y, row) in data.enumerate() {
    for (x, col) in (row.codepoints().enumerate()) {
      if col != "." {
        if result.at(col, default: none) == none {
          result.insert(col, ())
        }
        result.at(col).push((x, y))
      }
    }
  }
  result
}

let antinodes((a_x, a_y), (b_x, b_y)) = {
  let d_x = b_x - a_x
  let d_y = b_y - a_y
  ((a_x - d_x, a_y - d_y), (b_x + d_x, b_y + d_y))
}

(parse: parse, antennas: antennas, antinodes: antinodes)
```

```repl
data = parse(data)
dbg(data)
dbg(antennas(data))
dbg(antinodes((4, 3), (5, 5)))
dbg(antinodes((5, 5), (4, 3)))

let antennas = antennas(data)
let rows = data.len()
let cols = data.first().len()
let is-inside((x, y)) = 0 <= x and x < cols and 0 <= y and y < rows
dbg(
  antennas
    .values()
    .map(same-freq => {
      for (i, a) in same-freq.enumerate() {
        for b in same-freq.slice(i + 1) {
          antinodes(a, b)
        }
      }
    })
    .join()
    .filter(is-inside)
    .dedup()
    .len())
```

Ok y con la data posta...

```repl
let data = parse(read("2024-12-08.data"))
let antennas = antennas(data)
let rows = data.len()
let cols = data.first().len()
let is-inside((x, y)) = 0 <= x and x < cols and 0 <= y and y < rows
dbg(
  antennas
    .values()
    .map(same-freq => {
      for (i, a) in same-freq.enumerate() {
        for b in same-freq.slice(i + 1) {
          antinodes(a, b)
        }
      }
    })
    .join()
    .filter(is-inside)
    .dedup()
    .len())
```

=== Part Two

Watching over your shoulder as you work, one of The Historians asks if you took
the effects of resonant harmonics into your calculations.

Whoops!

After updating your model, it turns out that an antinode occurs at *any grid
position* exactly in line with at least two antennas of the same frequency,
regardless of distance. This means that some of the new antinodes will occur at
the position of each antenna (unless that antenna is the only one of its
frequency).

So, these three `T`-frequency antennas now create many antinodes:

```
T....#....
...T......
.T....#...
.........#
..#.......
..........
...#......
..........
....#.....
..........
```

In fact, the three `T`-frequency antennas are all exactly in line with two
antennas, so they are all also antinodes! This brings the total number of
antinodes in the above example to *`9`*.

The original example now has *`34`* antinodes, including the antinodes that
appear on every antenna:

```
##....#....#
.#.#....0...
..#.#0....#.
..##...0....
....0....#..
.#...#A....#
...#..#.....
#....#.#....
..#.....A...
....#....A..
.#........#.
...#......##
```

Calculate the impact of the signal using this updated model. *How many unique
locations within the bounds of the map contain an antinode?*

==== Resolución

```data
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
```

```repl
let solve(data) = {
  let data = parse(data)
  let antennas = antennas(data)
  let rows = data.len()
  let cols = data.first().len()
  let is-inside((x, y)) = 0 <= x and x < cols and 0 <= y and y < rows

  (antennas
    .values()
    .map(same-freq => {
      for (i, (ax, ay)) in same-freq.enumerate() {
        for (bx, by) in same-freq.slice(i + 1) {
          let dx = bx - ax
          let dy = by - ay

          // Forward
          let cx = ax
          let cy = ay
          while true {
            if not is-inside((cx, cy)) {
              break
            }
            ((cx, cy),)
            cx = cx + dx
            cy = cy + dy
          }

          cx = ax - dx
          cy = ay - dy
          while true {
            if not is-inside((cx, cy)) {
              break
            }
            ((cx, cy), )
            cx = cx - dx
            cy = cy - dy
          }
        }
      }
    })
    .join()
    .dedup()
    .len())
}
dbg(respuesta-ejemplo: solve(data))
dbg(respuesta-posta: solve(read("2024-12-08.data")))
```
