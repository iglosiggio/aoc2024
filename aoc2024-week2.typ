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

== Day 10: Hoof It

=== Part One

You all arrive at a Lava Production Facility on a floating island in the sky.
As the others begin to search the massive industrial complex, you feel a small
nose boop your leg and look down to discover a reindeer wearing a hard hat.

The reindeer is holding a book titled "Lava Island Hiking Guide". However, when
you open the book, you discover that most of it seems to have been scorched by
lava! As you're about to ask how you can help, the reindeer brings you a blank
topographic map of the surrounding area (your puzzle input) and looks up at you
excitedly.

Perhaps you can help fill in the missing hiking trails?

The topographic map indicates the *height* at each position using a scale from
`0` (lowest) to `9` (highest). For example:

```data
0123
1234
8765
9876
```

Based on un-scorched scraps of the book, you determine that a good hiking trail
is *as long as possible* and has an *even, gradual, uphill slope*. For all
practical purposes, this means that a *hiking trail* is any path that starts at
height `0`, ends at height `9`, and always increases by a height of exactly 1
at each step. Hiking trails never include diagonal steps - only up, down, left,
or right (from the perspective of the map).

You look up from the map and notice that the reindeer has helpfully begun to
construct a small pile of pencils, markers, rulers, compasses, stickers, and
other equipment you might need to update the map with hiking trails.

A *trailhead* is any position that starts one or more hiking trails - here,
these positions will always have height `0`. Assembling more fragments of
pages, you establish that a trailhead's *score* is the number of `9`-height
positions reachable from that trailhead via a hiking trail. In the above
example, the single trailhead in the top left corner has a score of `1` because
it can reach a single `9` (the one in the bottom left).

This trailhead has a score of `2`:

```
...0...
...1...
...2...
6543456
7.....7
8.....8
9.....9
```

(The positions marked `.` are impassable tiles to simplify these examples; they
do not appear on your actual topographic map.)

This trailhead has a score of `4` because every `9` is reachable via a hiking
trail except the one immediately to the left of the trailhead:

```
..90..9
...1.98
...2..7
6543456
765.987
876....
987....
```

This topographic map contains *two* trailheads; the trailhead at the top has a
score of `1`, while the trailhead at the bottom has a score of `2`:

```
10..9..
2...8..
3...7..
4567654
...8..3
...9..2
.....01
```

Here's a larger example:

```data
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
```

This larger example has 9 trailheads. Considering the trailheads in reading
order, they have scores of `5`, `6`, `5`, `3`, `1`, `3`, `5`, `3`, and `5`.
Adding these scores together, the sum of the scores of all trailheads is
*`36`*.

The reindeer gleefully carries over a protractor and adds it to the pile. *What
is the sum of the scores of all trailheads on your topographic map?*

==== Resolución

Ok, tengo que hacer lo siguiente:

1. Armar el grafo
2. Buscar los ceros
3. Por cada cero ver cuantos 9s son alcanzables

```definition
let armar-grafo(data) = {
  data = data.split("\n").filter(is_neq("")).map(call("codepoints"))
  data
  let grafo = (:)
  for (y, fila) in data.enumerate() {
    for (x, altura) in fila.enumerate() {
      let vecinos = ()
      let up = data.at(y - 1, default: ()).at(x, default: none)
      let down = data.at(y + 1, default: ()).at(x, default: none)
      let left = data.at(y).at(x - 1, default: none)
      let right = data.at(y).at(x + 1, default: none)

      altura = int(altura)

      if 0 < y and up != none and int(up) == altura + 1 {
        vecinos.push(str(x) + "," + str(y - 1) + "|" + up)
      }
      if down != none and int(down) == altura + 1 {
        vecinos.push(str(x) + "," + str(y + 1) + "|" + down)
      }
      if 0 < x and left != none and int(left) == altura + 1 {
        vecinos.push(str(x - 1) + "," + str(y) + "|" + left)
      }
      if right != none and int(right) == altura + 1 {
        vecinos.push(str(x + 1) + "," + str(y) + "|" + right)
      }
      grafo.insert(str(x) + "," + str(y) + "|" + str(altura), vecinos)
    }
  }
  return grafo
}

let buscar-ceros(grafo) = {
  grafo.keys().filter(k => k.last() == "0")
}

let contar-nueves-desde(grafo, cero) = {
  let visitados = (cero: true)
  let queue = (cero,)
  let nueves = 0
  while queue.len() != 0 {
    let next = queue.pop()
    visitados.insert(next, true)
    for vecino in grafo.at(next) {
      if visitados.at(vecino, default: false) { continue }
      visitados.insert(vecino, true)
      if vecino.last() == "9" {
        nueves = nueves + 1
        continue
      }
      queue.push(vecino)
    }
  }
  return nueves
}

(
  dia-10-armar-grafo: armar-grafo,
  dia-10-buscar-ceros: buscar-ceros,
  dia-10-contar-nueves: contar-nueves-desde)
```

```repl
for data in datas {
  let g = dia-10-armar-grafo(data)
  let ceros = dia-10-buscar-ceros(g)
  dbg(grafo: g)
  dbg(ceros: ceros)
  let total-score = 0
  for cero in ceros {
    let score = dia-10-contar-nueves(g, cero)
    dbg(cero: cero, score: score)
    total-score = total-score + score
  }
  dbg(total-score: total-score)
}
```

Y con la data posta...


```repl
let g = dia-10-armar-grafo(read("2024-12-10.data"))
let ceros = dia-10-buscar-ceros(g)
let total-score = ceros.map(v => dia-10-contar-nueves(g, v)).sum()
dbg(total-score: total-score)
```

=== Part Two

The reindeer spends a few minutes reviewing your hiking trail map before
realizing something, disappearing for a few minutes, and finally returning with
yet another slightly-charred piece of paper.

The paper describes a second way to measure a trailhead called its *rating*. A
trailhead's rating is the *number of distinct hiking trails* which begin at
that trailhead. For example:

```
.....0.
..4321.
..5..2.
..6543.
..7..4.
..8765.
..9....
```

The above map has a single trailhead; its rating is `3` because there are
exactly three distinct hiking trails which begin at that position:

```
.....0.   .....0.   .....0.
..4321.   .....1.   .....1.
..5....   .....2.   .....2.
..6....   ..6543.   .....3.
..7....   ..7....   .....4.
..8....   ..8....   ..8765.
..9....   ..9....   ..9....
```

Here is a map containing a single trailhead with rating `13`:

```
..90..9
...1.98
...2..7
6543456
765.987
876....
987....
```

This map contains a single trailhead with rating `227` (because there are `121`
distinct hiking trails that lead to the `9` on the right edge and `106` that
lead to the `9` on the bottom edge):

```
012345
123456
234567
345678
4.6789
56789.
```

Here's the larger example from before:

```data
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
```

Considering its trailheads in reading order, they have ratings of `20`, `24`,
`10`, `4`, `1`, `4`, `5`, `8`, and `5`. The sum of all trailhead ratings in
this larger example topographic map is *`81`*.

You're not sure how, but the reindeer seems to have crafted some tiny flags out
of toothpicks and bits of paper and is using them to mark trailheads on your
topographic map. *What is the sum of the ratings of all trailheads?*

==== Resolución

Lo mismo de antes pero ahora tengo que por cada vértice guardarme el score, lo
más fácil es arrancar de los nueves y esparcir el valor cuesta abajo. El bajón
de eso es que tengo que re-escribir todo jajaja.

```definition
let armar-grafo-al-reves(data) = {
  data = data.split("\n").filter(is_neq("")).map(call("codepoints"))
  data
  let grafo = (:)
  for (y, fila) in data.enumerate() {
    for (x, altura) in fila.enumerate() {
      let vecinos = ()
      let up = data.at(y - 1, default: ()).at(x, default: none)
      let down = data.at(y + 1, default: ()).at(x, default: none)
      let left = data.at(y).at(x - 1, default: none)
      let right = data.at(y).at(x + 1, default: none)

      altura = int(altura)

      if 0 < y and up != none and int(up) == altura - 1 {
        vecinos.push(str(x) + "," + str(y - 1) + "|" + up)
      }
      if down != none and int(down) == altura - 1 {
        vecinos.push(str(x) + "," + str(y + 1) + "|" + down)
      }
      if 0 < x and left != none and int(left) == altura - 1 {
        vecinos.push(str(x - 1) + "," + str(y) + "|" + left)
      }
      if right != none and int(right) == altura - 1 {
        vecinos.push(str(x + 1) + "," + str(y) + "|" + right)
      }
      grafo.insert(str(x) + "," + str(y) + "|" + str(altura), vecinos)
    }
  }
  return grafo
}

let buscar-nueves(grafo) = {
  grafo.keys().filter(k => k.last() == "9")
}

let calcular-raitings(grafo) = {
  let nueves = buscar-nueves(grafo)

  let ratings = (:)
  for nueve in nueves {
    ratings.insert(nueve, 1)
  }
  let rating = 0

  let visitados = (:)
  let queue = nueves
  while queue.len() != 0 {
    let next = queue.remove(0)
    let mi-rating = ratings.at(next)
    if next.last() == "0" {
      rating = rating + mi-rating
      continue
    }
    visitados.insert(next, true)
    for vecino in grafo.at(next) {
      ratings.insert(vecino, ratings.at(vecino, default: 0) + mi-rating)
      if visitados.at(vecino, default: false) { continue }
      visitados.insert(vecino, true)
      queue.push(vecino)
    }
  }
  return rating
}

(
  dia-10-armar-grafo-al-reves: armar-grafo-al-reves,
  dia-10-buscar-nueves: buscar-nueves,
  dia-10-calcular-raitings: calcular-raitings)
```

```repl
for data in datas {
  let g = dia-10-armar-grafo-al-reves(data)
  dbg(total-score: dia-10-calcular-raitings(g))
}
{
  let g = dia-10-armar-grafo-al-reves(read("2024-12-10.data"))
  dbg(total-score: dia-10-calcular-raitings(g))
}
```

== Day 11: Plutonian Pebbles

The ancient civilization on Pluto was known for its ability to manipulate
spacetime, and while The Historians explore their infinite corridors, you've
noticed a strange set of physics-defying stones.

At first glance, they seem like normal stones: they're arranged in a perfectly
*straight line*, and each stone has a *number* engraved on it.

The strange part is that every time you blink, the stones *change*.

Sometimes, the number engraved on a stone changes. Other times, a stone might
*split in two*, causing all the other stones to shift over a bit to make room
in their perfectly straight line.

As you observe them for a while, you find that the stones have a consistent
behavior. Every time you blink, the stones each *simultaneously* change
according to *the first applicable rule* in this list:

- If the stone is engraved with the number `0`, it is replaced by a stone
  engraved with the number `1`.
- If the stone is engraved with a number that has an *even* number of digits,
  it is replaced by *two stones*. The left half of the digits are engraved on
  the new left stone, and the right half of the digits are engraved on the new
  right stone. (The new numbers don't keep extra leading zeroes: 1000 would
  become stones `10` and `0`.)
- If none of the other rules apply, the stone is replaced by a new stone; the
  old stone's number *multiplied by 2024* is engraved on the new stone.

No matter how the stones change, their *order is preserved*, and they stay on
their perfectly straight line.

How will the stones evolve if you keep blinking at them? You take a note of the
number engraved on each stone in the line (your puzzle input).

If you have an arrangement of five stones engraved with the numbers
#raw("0 1 10 99 999") and you blink once, the stones transform as follows:

- The first stone, `0`, becomes a stone marked `1`.
- The second stone, `1`, is multiplied by `2024` to become `2024`.
- The third stone, `10`, is split into a stone marked `1` followed by a stone
  marked `0`.
- The fourth stone, `99`, is split into two stones marked `9`.
- The fifth stone, `999`, is replaced by a stone marked `2021976`.

So, after blinking once, your five stones would become an arrangement of seven
stones engraved with the numbers `1 2024 1 0 9 9 2021976`.

Here is a longer example:

```
Initial arrangement:
125 17

After 1 blink:
253000 1 7

After 2 blinks:
253 0 2024 14168

After 3 blinks:
512072 1 20 24 28676032

After 4 blinks:
512 72 2024 2 0 2 4 2867 6032

After 5 blinks:
1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32

After 6 blinks:
2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2
```

In this example, after blinking six times, you would have `22` stones. After
blinking `25` times, you would have `55312` stones!

Consider the arrangement of stones in front of you. *How many stones will you
have after blinking 25 times?*

==== Resolución

```definition
let even(n) = n.bit-and(1) == 0

let apply-rules(v) = {
  if v == 0 { return (1,) }
  let str-v = str(v)
  if even(str-v.len()) {
    let mid = str-v.len().bit-rshift(1)
    return (int(str-v.slice(0, mid)), int(str-v.slice(mid)))
  }
  return (v * 2024,)
}
(apply-rules: apply-rules)
```

```repl
dbg(zero: apply-rules(0))
dbg(odd-digits: apply-rules(9))
dbg(even-digits: apply-rules(12))
dbg(even-digits: apply-rules(1234))
dbg(even-digits: apply-rules(1000))
let state = (125, 17)
for i in range(6) {
  dbg(state)
  state = state.map(apply-rules).flatten()
}

let state = (125, 17)
for i in range(25) {
  state = state.map(apply-rules).flatten()
}
dbg(after-25: state.len())
```

Ok, y con el input posta?
```repl
// Esta es la solución vieja, el tema es que es re lenta
//let state = read("2024-12-11.data").split().map(int)
//dbg(state)
//for i in range(25) {
//  state = state.map(apply-rules).flatten()
//}
//dbg(after-25: state.len())

let data = read("2024-12-11.data").split().map(int)

let state = (:)
for rock in data {
  state.insert(str(rock), 1)
}

for i in range(25) {
  let next-state = (:)
  for (rock, count) in state.pairs() {
    for next-rock in apply-rules(int(rock)) {
      let str-next-rock = str(next-rock)
      next-state.insert(str-next-rock, next-state.at(str-next-rock, default: 0) + count)
    }
  }
  state = next-state
}
dbg(state.values().sum())
```

=== Part Two

The Historians sure are taking a long time. To be fair, the infinite corridors
*are* very large.

*How many stones would you have after blinking a total of 75 times?*

```repl
let data = read("2024-12-11.data").split().map(int)

let state = (:)
for rock in data {
  state.insert(str(rock), 1)
}

for i in range(75) {
  let next-state = (:)
  for (rock, count) in state.pairs() {
    for next-rock in apply-rules(int(rock)) {
      let str-next-rock = str(next-rock)
      next-state.insert(str-next-rock, next-state.at(str-next-rock, default: 0) + count)
    }
  }
  state = next-state
}
dbg(state.values().sum())
```

== Day 12: Garden Groups


=== Part One

No voy a copiarlo, son las 2am

==== Resolución

```data
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
```

```repl
let build-graph(data) = {
  let g = (:)
  data = data.split("\n").filter(is_neq(""))

  let rows = data.len()
  let cols = data.first().len()

  let in-range((x, y)) = 0 <= x and x < cols and 0 <= y and y < rows
  let vert-name((x, y)) = str(x) + "," + str(y)
  let at((x, y)) = data.at(y).at(x)

  for (y, row) in data.enumerate() {
    for (x, col) in row.codepoints().enumerate() {
      let vecinos = ()
      for v in ((x, y - 1), (x, y + 1), (x - 1, y), (x + 1, y)) {
        if in-range(v) and at(v) == col {
          vecinos.push(vert-name(v))
        }
      }
      g.insert(vert-name((x, y)), vecinos)
    }
  }
  return g
}

let componentes-conexos(g) = {
  let visitados = (:)
  let componentes = ()

  for v in g.keys() {
    if visitados.at(v, default: false) { continue }
    let queue = (v,)
    let componente = (area: 0, perimetro: 0, v: v)
    while queue.len() != 0 {
      let c = queue.pop()
      if visitados.at(c, default: false) { continue }

      visitados.insert(c, true)

      componente.area = componente.area + 1
      componente.perimetro = componente.perimetro + 4 - g.at(c).len()
      for vecino in g.at(c) {
        if visitados.at(vecino, default: false) { continue }
	queue.push(vecino)
      }
    }
    componentes.push(componente)
  }
  return componentes
}

let solve(data, debug: true) = {
  let g = build-graph(data)
  let c = componentes-conexos(g)
  let r = c.map(v => v.area * v.perimetro).sum()
  if debug {
    dbg(g)
    dbg(c)
    dbg(answer: r)
  } else {
    return r
  }
}

solve(data)
dbg(solucion: solve(read("2024-12-12.data"), debug: false))
```

=== Part Two


Oh no

== Day 13: Claw Contraption

=== Part One

Next up: the lobby of a resort on a tropical island. The Historians take a
moment to admire the hexagonal floor tiles before spreading out.

Fortunately, it looks like the resort has a new arcade! Maybe you can win some
prizes from the claw machines?

The claw machines here are a little unusual. Instead of a joystick or
directional buttons to control the claw, these machines have two buttons
labeled `A` and `B`. Worse, you can't just put in a token and play; it costs *3
tokens* to push the `A` button and *1 token* to push the `B` button.

With a little experimentation, you figure out that each machine's buttons are
configured to move the claw a specific amount to the *right* (along the `X`
axis) and a specific amount forward (along the `Y` axis) each time that button
is pressed.

Each machine contains one *prize*; to win the prize, the claw must be
positioned *exactly* above the prize on both the `X` and `Y` axes.

You wonder: what is the smallest number of tokens you would have to spend to
win as many prizes as possible? You assemble a list of every machine's button
behavior and prize location (your puzzle input). For example:

```data
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
```

This list describes the button configuration and prize location of four
different claw machines.

For now, consider just the first claw machine in the list:

- Pushing the machine's `A` button would move the claw `94` units along the `X` axis
  and `34` units along the `Y` axis.
- Pushing the `B` button would move the claw `22` units along the `X` axis and `67`
  units along the `Y` axis.
- The prize is located at `X=8400`, `Y=5400`; this means that from the claw's
  initial position, it would need to move exactly `8400` units along the `X` axis
  and exactly `5400` units along the `Y` axis to be perfectly aligned with the
  prize in this machine.

The cheapest way to win the prize is by pushing the `A` button `80` times and
the `B` button `40` times. This would line up the claw along the `X` axis
(because `80*94 + 40*22 = 8400`) and along the `Y` axis (because
`80*34 + 40*67 = 5400`). Doing this would cost `80*3` tokens for the `A`
presses and `40*1` for the `B` presses, a total of *`280`* tokens.

For the second and fourth claw machines, there is no combination of `A` and `B`
presses that will ever win a prize.

For the third claw machine, the cheapest way to win the prize is by pushing the
`A` button `38` times and the `B` button `86` times. Doing this would cost a
total of *`200`* tokens.

So, the most prizes you could possibly win is two; the minimum tokens you would
have to spend to win all (two) prizes is *`480`*.

You estimate that each button would need to be pressed *no more than 100 times*
to win a prize. How else would someone be expected to play?

Figure out how to win as many prizes as possible. *What is the fewest tokens
you would have to spend to win all possible prizes?*

==== Resolución

Ok, la idea es que $mat(A_x, B_x; A_y, B_y)^(-1)p$ me da la rta. Esto es porque
$mat(A_x, B_x; A_y, B_y)mat(1; 0) = A$ y
$mat(A_x, B_x; A_y, B_y)mat(0; B) = B$. Si el resultado no posee coordenadas
enteras entonces no hay solución. Primero voy a parsear el input, después
reviso cómo se invertía una matriz.

```repl
let parse(data) = (
  data
    .trim()
    .split("\n\n")
    .map(call("split", "\n"))
    .map(((a, b, pos)) => {
      a = a.match(regex("Button A: X\+(\d+), Y\+(\d+)")).captures.map(int)
      b = b.match(regex("Button B: X\+(\d+), Y\+(\d+)")).captures.map(int)
      pos = pos.match(regex("Prize: X=(\d+), Y=(\d+)")).captures.map(int)
      (a: a, b: b, pos: pos)
    }))

let invert((Ax, Ay), (Bx, By)) = {
  let k = 1 / (Ax * By - Bx * Ay)
  return (By * k, -Bx * k, -Ay * k, Ax * k)
}

let solve(data) = {
  let result = 0
  for problem in parse(data) {
    let m = invert(problem.a, problem.b)
    let p = problem.pos
    let Apress = m.at(0) * p.at(0) + m.at(1) * p.at(1)
    let Bpress = m.at(2) * p.at(0) + m.at(3) * p.at(1)
    if 0.0001 < calc.abs(calc.round(Apress) - Apress) { continue }
    if 0.0001 < calc.abs(calc.round(Bpress) - Bpress) { continue }
    Apress = calc.round(Apress)
    Bpress = calc.round(Bpress)
    result = result + Apress * 3 + Bpress
  }
  return result
}

dbg(parse(data))
dbg(solve(data))
dbg(answer: solve(read("2024-12-13.data")))
```

=== Part Two

As you go to win the first prize, you discover that the claw is nowhere near
where you expected it would be. Due to a unit conversion error in your
measurements, the position of every prize is actually `10000000000000` higher
on both the `X` and `Y` axis!

Add `10000000000000` to the `X` and `Y` position of every prize. After making
this change, the example above would now look like this:

```
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=10000000008400, Y=10000000005400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=10000000012748, Y=10000000012176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=10000000007870, Y=10000000006450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=10000000018641, Y=10000000010279
```

Now, it is only possible to win a prize on the second and fourth claw machines.
Unfortunately, it will take *many more than `100` presses* to do so.

Using the corrected prize coordinates, figure out how to win as many prizes as
possible. *What is the fewest tokens you would have to spend to win all
possible prizes?*

```data
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
```

```repl
let offset = 10000000000000
let parse(data) = (
  data
    .trim()
    .split("\n\n")
    .map(call("split", "\n"))
    .map(((a, b, pos)) => {
      a = a.match(regex("Button A: X\+(\d+), Y\+(\d+)")).captures.map(int)
      b = b.match(regex("Button B: X\+(\d+), Y\+(\d+)")).captures.map(int)
      pos = pos.match(regex("Prize: X=(\d+), Y=(\d+)")).captures.map(int)
      (a: a, b: b, pos: pos.map(v => v + offset))
    }))

let invert((Ax, Ay), (Bx, By)) = {
  let k = 1 / (Ax * By - Bx * Ay)
  return (By * k, -Bx * k, -Ay * k, Ax * k)
}

let solve(data) = {
  let result = 0
  for problem in parse(data) {
    let m = invert(problem.a, problem.b)
    let p = problem.pos
    let Apress = m.at(0) * p.at(0) + m.at(1) * p.at(1)
    let Bpress = m.at(2) * p.at(0) + m.at(3) * p.at(1)
    if 0.0001 < calc.abs(calc.round(Apress) - Apress) { continue }
    if 0.0001 < calc.abs(calc.round(Bpress) - Bpress) { continue }
    Apress = calc.round(Apress)
    Bpress = calc.round(Bpress)
    result = result + Apress * 3 + Bpress
  }
  return result
}

dbg(parse(data))
dbg(solve(data))
dbg(answer: solve(read("2024-12-13.data")))
```
