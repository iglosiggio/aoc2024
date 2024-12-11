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

Finalmente, una visualización de la rta :)
```repl
import "@preview/cetz:0.3.0"

let data = parse(read("2024-12-08.data"))
let antennas = antennas(data)
let antenna-types = antennas.keys()

let cmap = color.map.turbo
let conversion-factor = cmap.len() / antenna-types.len()
let type-to-color = (:)
for (i, type) in antenna-types.enumerate() {
  type-to-color.insert(type, cmap.at(calc.floor(i * conversion-factor)))
}

let rows = data.len()
let cols = data.first().len()
let is-inside((x, y)) = 0 <= x and x < cols and 0 <= y and y < rows

cetz.canvas({
  import cetz.draw: *
  scale(31%)

  for (y, row) in data.enumerate() {
    y = y
    for (x, col) in row.codepoints().enumerate() {
      x = x
      let color = type-to-color.at(col, default: none)
      if color != none {
        circle((x, y), fill: color, stroke: color, radius: 0.4)
      }
    }
  }

  for (freq, antennas) in antennas.pairs() {
    let color = type-to-color.at(freq)
    for (i, (ax, ay)) in antennas.enumerate() {
      for (bx, by) in antennas.slice(i + 1) {
        let dx = bx - ax
        let dy = by - ay

        let dnorm = calc.sqrt(dx * dx + dy * dy)
        let ndx = dx / dnorm
        let ndy = dy / dnorm

        let p = (ax - dx, ay - dy)
        if is-inside(p) {
          circle(p, radius: 0.1, stroke: color, fill: color)
          line(p, (p.at(0) + ndx, p.at(1) + ndy), stroke: color)
          line((ax, ay), (ax - ndx, ay - ndy), stroke: color)
        }
        let p = (bx + dx, by + dy)
        if is-inside(p) {
          circle(p, radius: 0.1, stroke: color, fill: color)
          line(p, (p.at(0) - ndx, p.at(1) - ndy), stroke: color)
          line((bx, by), (bx + ndx, by + ndy), stroke: color)
        }
      }
    }
  }
})
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

== Day 9: Disk Fragmenter

=== Part One

Another push of the button leaves you in the familiar hallways of some friendly
amphipods! Good thing you each somehow got your own personal mini submarine.
The Historians jet away in search of the Chief, mostly by driving directly into
walls.

While The Historians quickly figure out how to pilot these things, you notice
an amphipod in the corner struggling with his computer. He's trying to make
more contiguous free space by compacting all of the files, but his program
isn't working; you offer to help.

He shows you the *disk map* (your puzzle input) he's already generated. For
example:

```data
2333133121414131402
```

The disk map uses a dense format to represent the layout of *files* and *free
space* on the disk. The digits alternate between indicating the length of a
file and the length of free space.

So, a disk map like `12345` would represent a one-block file, two blocks of
free space, a three-block file, four blocks of free space, and then a
five-block file. A disk map like `90909` would represent three nine-block files
in a row (with no free space between them).

Each file on disk also has an *ID number* based on the order of the files as
they appear *before* they are rearranged, starting with ID `0`. So, the disk
map `12345` has three files: a one-block file with ID `0`, a three-block file
with ID `1`, and a five-block file with ID `2`. Using one character for each
block where digits are the file ID and `.` is free space, the disk map `12345`
represents these individual blocks:

```
0..111....22222
```

The first example above, `2333133121414131402`, represents these individual
blocks:

```
00...111...2...333.44.5555.6666.777.888899
```

The amphipod would like to *move file blocks one at a time* from the end of the
disk to the leftmost free space block (until there are no gaps remaining
between file blocks). For the disk map `12345`, the process looks like this:

```
0..111....22222
02.111....2222.
022111....222..
0221112...22...
02211122..2....
022111222......
```

The first example requires a few more steps:

```
00...111...2...333.44.5555.6666.777.888899
009..111...2...333.44.5555.6666.777.88889.
0099.111...2...333.44.5555.6666.777.8888..
00998111...2...333.44.5555.6666.777.888...
009981118..2...333.44.5555.6666.777.88....
0099811188.2...333.44.5555.6666.777.8.....
009981118882...333.44.5555.6666.777.......
0099811188827..333.44.5555.6666.77........
00998111888277.333.44.5555.6666.7.........
009981118882777333.44.5555.6666...........
009981118882777333644.5555.666............
00998111888277733364465555.66.............
0099811188827773336446555566..............
```

The final step of this file-compacting process is to update the *filesystem
checksum*. To calculate the checksum, add up the result of multiplying each of
these blocks' position with the file ID number it contains. The leftmost block
is in position `0`. If a block contains free space, skip it instead.

Continuing the first example, the first few blocks' position multiplied by its
file ID number are `0 * 0 = 0`, `1 * 0 = 0`, `2 * 9 = 18`, `3 * 9 = 27`,
`4 * 8 = 32`, and so on. In this example, the checksum is the sum of these,
*`1928`*.

Compact the amphipod's hard drive using the process he requested. *What is the
resulting filesystem checksum?* _(Be careful copy/pasting the input for this
puzzle; it is a single, very long line.)_

==== Resolución

Acá estoy haciendo trampa xq en realidad lo resolví en JS hablando con una
amiga hace unos días. Voy a intentar reimplementar esa solución súper
imperativa acá.

```definition
let even(n) = n.bit-and(1) == 0

let solve(data, debug: true) = {
  data = data.codepoints().filter(is_neq("\n")).map(int)

  let disk = ()

  let i = 0
  let len = data.len()
  let file_id = 0
  while i < len {
    while i < len {
      let size = data.at(i)
      if (even(i)) {
        while 0 < size {
          disk.push(file_id)
          size = size - 1
        }
        file_id = file_id + 1
      } else {
        while 0 < size {
          disk.push(-1)
          size = size - 1
        }
      }
      i = i + 1
      if i.bit-and(0xFF) == 0 { break }
    }
  }

  i = 0
  len = disk.len()
  let j = len - 1
  while i < j {
    while i < j {
      if disk.at(i) != -1 {
        i = i + 1
        if i.bit-and(0xFF) == 0 { break }
        continue
      }
      if disk.at(j) == -1 {
        j = j - 1
        if j.bit-and(0xFF) == 0 { break }
        continue
      }
      disk.at(i) = disk.at(j)
      disk.at(j) = -1
      if (debug) {
        dbg(raw(disk.map(v => if v == -1 { "." } else { str(v) }).join()))
      }
    }
  }

  i = 0
  let result = 0
  while disk.at(i) != -1 {
    while disk.at(i) != -1 {
      result = result + i * disk.at(i)
      i = i + 1
      if i.bit-and(0xFF) == 0 { break }
    }
  }

  if debug {
    dbg(result)
  } else {
    return result
  }
}

(solve-2024-12-09: solve)
```

```repl
solve-2024-12-09(data)
dbg(solve-2024-12-09(read("2024-12-09.data"), debug: false))
```

=== Part Two

Upon completion, two things immediately become clear. First, the disk
definitely has a lot more contiguous free space, just like the amphipod hoped.
Second, the computer is running much more slowly! Maybe introducing all of that
file system fragmentation was a bad idea?

The eager amphipod already has a new plan: rather than move individual blocks,
he'd like to try compacting the files on his disk by moving *whole files*
instead.

This time, attempt to move whole files to the leftmost span of free space
blocks that could fit the file. Attempt to move each file exactly once in order
of *decreasing file ID number* starting with the file with the highest file ID
number. If there is no span of free space to the left of a file that is large
enough to fit the file, the file does not move.

The first example from above now proceeds differently:

```
00...111...2...333.44.5555.6666.777.888899
0099.111...2...333.44.5555.6666.777.8888..
0099.1117772...333.44.5555.6666.....8888..
0099.111777244.333....5555.6666.....8888..
00992111777.44.333....5555.6666.....8888..
```

The process of updating the filesystem checksum is the same; now, this
example's checksum would be *`2858`*.

Start over, now compacting the amphipod's hard drive using this new method
instead. *What is the resulting filesystem checksum?*

==== Resolución

```definition
let even(n) = n.bit-and(1) == 0

let compact-free(data-in) = {
  let current-chunk-start = 0
  let current-size = 0
  let current-offset = 0
  let data-out = ()
  for (offset, size) in data-in {
    if current-offset != offset {
      if current-size != 0 {
        data-out.push((current-chunk-start, current-size))
      }
      current-chunk-start = offset
      current-size = size
      current-offset = offset + size
    } else {
      current-size = current-size + size
      current-offset = current-offset + size
    }
  }
  if current-size != 0 {
    data-out.push((current-chunk-start, current-size))
  }
  return data-out
}

let solve(data, debug: true) = {
  data = data.codepoints().filter(is_neq("\n")).map(int)

  let files = ()
  let free-slots = ()

  let i = 0
  let len = data.len()
  let file-id = 0
  let disk-offset = 0
  while i < len {
    while i < len {
      let size = data.at(i)
      if size != 0 {
        if (even(i)) {
          files.push((disk-offset, size, file-id))
        } else {
          free-slots.push((disk-offset, size))
        }
      }

      if (even(i)) {
        file-id = file-id + 1
      }

      disk-offset = disk-offset + size
      i = i + 1
      if i.bit-and(0xFF) == 0 { break }
    }
  }

  let compacted-files = ()
  for (offset, size, file-id) in files.rev() {
    for (i, (free-offset, free-size)) in free-slots.enumerate() {
      if offset < free-offset { break }
      if free-size < size { continue }
      free-slots.at(i) = (free-offset + size, free-size - size)
      free-slots.push((offset, size))
      free-slots = free-slots.sorted(key: v => v.at(0))
      free-slots = compact-free(free-slots)
      offset = free-offset
      break
    }
    compacted-files.push((offset, size, file-id))
  }
  compacted-files = compacted-files.sorted(key: v => v.at(0))

  if debug {
    dbg((compacted-files + free-slots)
      .sorted(key: v => v.at(0))
      .map(thing => {
        if thing.len() == 2 {
          "." * thing.at(1)
        } else {
          str(thing.at(2)) * thing.at(1)
        }
      })
      .join())
  }

  let result = compacted-files.map(((offset, size, file-id)) => {
    let sum-to-start = offset * (offset - 1) / 2
    let sum-to-end = (offset + size) * (offset + size - 1) / 2
    (sum-to-end - sum-to-start) * file-id
  }).sum()
  if (debug) {
    dbg(result)
  } else {
    return result
  }
}

(solve-2024-12-09b: solve)
```

```data
2333133121414131402
```

```repl
solve-2024-12-09b(data)
solve-2024-12-09b("0010051006061606")
dbg(solve-2024-12-09b(read("2024-12-09.data"), debug: false))
```
