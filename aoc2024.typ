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
= Advent of Code 2024

== Pruebas iniciales

Una cosa que necesito es una forma de escribir código que se muestre
highlighteada y al mismo tiempo se evalúe. Tengo una solución medio bestia que
me permite escribir definiciones por un lado:

```definition
let x = 0
let y = 1
(x: x, y: y)
```

E invocaciones al REPL por otro:

```repl
[El valor de $X$ es #x. El valor de $Y$ es #y]
```

El problema de esta técnica es que hay que listar de forma explícita los
símbolos que se exportan en cada bloque.

```definition
x = x + 1
y = y + 1
(x: x, y: y)
```

Y que las llamadas al repl no tienen side-effects:

```repl
x = x + 1
y = y + 1
(x, y)
```

```repl
x = x + 1
y = y + 1
(x, y)
```

== Primer ejercicio del año pasado

=== Day 1: Trebuchet?!

Something is wrong with global snow production, and you've been selected to
take a look. The Elves have even given you a map; on it, they've used stars to
mark the top fifty locations that are likely to be having problems.

You've been doing this long enough to know that to restore snow operations, you
need to check all fifty stars by December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each
day in the Advent calendar; the second puzzle is unlocked when you complete the
first. Each puzzle grants one star. Good luck!

You try to ask why they can't just use a weather machine ("not powerful
enough") and where they're even sending you ("the sky") and why your map looks
mostly blank ("you sure ask a lot of questions") and hang on did you just say
the sky ("of course, where do you think snow comes from") when you realize that
the Elves are already loading you into a trebuchet ("please hold still, we need
to strap you in").

As they're making the final adjustments, they discover that their calibration
document (your puzzle input) has been *amended* by a very young Elf who was
apparently just excited to show off her art skills. Consequently, the Elves are
having trouble reading the values on the document.

The newly-improved calibration document consists of lines of text; each line
originally contained a specific *calibration value* that the Elves now need to
recover. On each line, the calibration value can be found by combining the
*first digit* and the *last digit* (in that order) to form a single *two-digit
number*.

For example:

```data
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
```

In this example, the calibration values of these four lines are `12`, `38`,
`15`, and `77`. Adding these together produces `142`.

Consider your entire calibration document. *What is the sum of all of the
calibration values?*

=== Resolución

Tengo un macro que pone el último input como global:
```repl
data
```

Intento la resolución:

```definition
let ejercicio(data) = {
  let result = 0
  let lines = data.split()
  for line in lines {
    let matches = line.matches(regex("\d"))
    result = result + int(matches.first().text + matches.last().text)
  }
  result
}
(ejercicio: ejercicio)
```

```repl
ejercicio(data)
```

=== Data posta

```repl
let data = read("2023-example.data")
ejercicio(data)
```

== Part Two

Your calculation isn't quite right. It looks like some of the digits are
actually *spelled out with letters*: `one`, `two`, `three`, `four`, `five`,
`six`, `seven`, `eight`, and `nine` also count as valid "digits".

Equipped with this new information, you now need to find the real first and
last digit on each line. For example:

```data
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

In this example, the calibration values are `29`, `83`, `13`, `24`, `42`, `14`,
and `76`. Adding these together produces `281`.

*What is the sum of all of the calibration values?*

```definition
let ejercicio-2(data) = {
  let text2num = (
    zero: 0,
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    five: 5,
    six: 6,
    seven: 7,
    eight: 8,
    nine: 9,
  )
  let lines = data.split()
  let result = 0
  for line in lines {
    let matches = (
        line.matches(regex("\d"))
      + line.matches(regex("zero"))
      + line.matches(regex("one"))
      + line.matches(regex("two"))
      + line.matches(regex("three"))
      + line.matches(regex("four"))
      + line.matches(regex("five"))
      + line.matches(regex("six"))
      + line.matches(regex("seven"))
      + line.matches(regex("eight"))
      + line.matches(regex("nine"))).sorted(key: v => v.start)
    let a = matches.first().text
    let b = matches.last().text
    if a.len() != 1 {
      a = text2num.at(a)
    } else {
      a = int(a)
    }
    if b.len() != 1 {
      b = text2num.at(b)
    } else {
      b = int(b)
    }
    let n = a * 10 + b
    result = result + n
  }
  result
}

(ejercicio-2: ejercicio-2)
```

```repl
ejercicio-2(data)
```

=== Data posta

```repl
let data = read("2023-example.data")
ejercicio-2(data)
```

=== Hola fran

```data
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

```repl
let lines = data.split()
for line in lines {
  let matches = (
      line.matches(regex("\d"))
    + line.matches(regex("zero"))
    + line.matches(regex("one"))
    + line.matches(regex("two"))
    + line.matches(regex("three"))
    + line.matches(regex("four"))
    + line.matches(regex("five"))
    + line.matches(regex("six"))
    + line.matches(regex("seven"))
    + line.matches(regex("eight"))
    + line.matches(regex("nine"))).sorted(key: v => v.start)
  dbg(count: matches.len(), matches.first().text, matches.last().text)
}
dbg(a: 123, b: 321, arr: (1, 2, 3), "pos1", [*pos2*], $"pos"^3$)
```

```repl
dbg(1, 2, 3)
```

== Day 10: Pipe Maze

=== Part One

You use the hang glider to ride the hot air from Desert Island all the way up
to the floating metal island. This island is surprisingly cold and there
definitely aren't any thermals to glide on, so you leave your hang glider
behind.

You wander around for a while, but you don't find any people or animals.
However, you do occasionally find signposts labeled "Hot Springs" pointing in a
seemingly consistent direction; maybe you can find someone at the hot springs
and ask them where the desert-machine parts are made.

The landscape here is alien; even the flowers and trees are made of metal. As
you stop to admire some metal grass, you notice something metallic scurry away
in your peripheral vision and jump into a big pipe! It didn't look like any
animal you've ever seen; if you want a better look, you'll need to get ahead of
it.

Scanning the area, you discover that the entire field you're standing on is
densely packed with pipes; it was hard to tell at first because they're the
same metallic silver color as the "ground". You make a quick sketch of all of
the surface pipes you can see (your puzzle input).

The pipes are arranged in a two-dimensional grid of *tiles*:
- | is a *vertical pipe* connecting north and south.
- - is a *horizontal pipe* connecting east and west.
- L is a *90-degree bend* connecting north and east.
- J is a *90-degree bend* connecting north and west.
- 7 is a *90-degree bend* connecting south and west.
- F is a *90-degree bend* connecting south and east.
- . is *ground*; there is no pipe in this tile.
- S is the *starting position* of the animal; there is a pipe on this tile, but
  your sketch doesn't show what shape the pipe has.

Based on the acoustics of the animal's scurrying, you're confident the pipe
that contains the animal is *one large, continuous loop*.

For example, here is a square loop of pipe:

```data
.....
.F-7.
.|.|.
.L-J.
.....
```

If the animal had entered this loop in the northwest corner, the sketch would
instead look like this:

```data
.....
.S-7.
.|.|.
.L-J.
.....
```

In the above diagram, the S tile is still a 90-degree F bend: you can tell
because of how the adjacent pipes connect to it.

Unfortunately, there are also many pipes that *aren't connected to the loop*!
This sketch shows the same loop as above:

```data
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
```

In the above diagram, you can still figure out which pipes form the main loop:
they're the ones connected to S, pipes those pipes connect to, pipes *those*
pipes connect to, and so on. Every pipe in the main loop connects to its two
neighbors (including S, which will have exactly two pipes connecting to it, and
which is assumed to connect back to those two pipes).

Here is a sketch that contains a slightly more complex main loop:

```data
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
```

Here's the same example sketch with the extra, non-main-loop pipe tiles also
shown:

```
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
```

If you want to get out *ahead of the animal*, you should find the tile in the
loop that is *farthest* from the starting position. Because the animal is in
the pipe, it doesn't make sense to measure this by direct distance. Instead,
you need to find the tile that would take the longest number of steps *along
the loop* to reach from the starting point - regardless of which way around the
loop the animal went.

In the first example with the square loop:

```data
.....
.S-7.
.|.|.
.L-J.
.....
```

You can count the distance each tile in the loop is from the starting point
like this:

```data
.....
.012.
.1.3.
.234.
.....
```

In this example, the farthest point from the start is *4* steps away.

Here's the more complex loop again:

```data
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
```

Here are the distances for each tile on that loop:

```
..45.
.236.
01.78
14567
23...
```

Find the single giant loop starting at S. *How many steps along the loop does
it take to get from the starting position to the point farthest from the
starting position?*

== Resolución

Lo primero que me gustaría es poder dibujar los cosos estos...

```repl
let i = 0
enum(..datas.map(data => {
    let lines = data.split()

    grid(
      columns: (1em,) * lines.first().len(),
      rows: 1em,
      ..lines.map(l => {
        l.codepoints().map(c => {
          if (c == "S") {
            circle(width: 100%)
          } else if (c == "F") {
            line(start: (50%, 100%), end: (100%, 50%))
          } else if (c == "-") {
            line(start: (0%, 50%), end: (100%, 50%))
          } else if (c == "7") {
            line(start: (0%, 50%), end: (50%, 100%))
          } else if (c == "|") {
            line(start: (50%, 0%), end: (50%, 100%))
          } else if (c == "J") {
            line(start: (0%, 50%), end: (50%, 0%))
          } else if (c == "L") {
            line(start: (50%, 0%), end: (100%, 50%))
          }
        })
      }).flatten()
    )
  }).map(box)
)
```

Vamos a meterlo en una función:
```definition
let draw(data) = {
  let lines = data.split()

  grid(
    columns: (1em,) * lines.first().len(),
    rows: 1em,
    ..lines.map(l => {
      l.codepoints().map(c => {
        if (c == "S") {
          circle(width: 100%)
        } else if (c == "F") {
          line(start: (50%, 100%), end: (100%, 50%))
        } else if (c == "-") {
          line(start: (0%, 50%), end: (100%, 50%))
        } else if (c == "7") {
          line(start: (0%, 50%), end: (50%, 100%))
        } else if (c == "|") {
          line(start: (50%, 0%), end: (50%, 100%))
        } else if (c == "J") {
          line(start: (0%, 50%), end: (50%, 0%))
        } else if (c == "L") {
          line(start: (50%, 0%), end: (100%, 50%))
        }
      })
    }).flatten()
  )
}
(draw-map: draw)
```

Mmmm también peudo usar graphviz para dibujar grafos.

```definition
let graph-to-graphviz(graph, ..args) = {
  import "@preview/diagraph:0.3.0": render
  render({
    "digraph {"
      for (a, neighbours) in graph.pairs() {
        //"\""; a; "\";"
        for b in neighbours {
          "\""; a; "\" -> \""; b; "\";"
	}
      }
    "}"
  }, ..args)
}
(graph-to-graphviz: graph-to-graphviz)
```

```repl
graph-to-graphviz((
  A: ("B", "C", "D"),
  B: ("C", "D"),
  C: ("A",),
))
```

Ahora me pongo a pensar la resolución:

```repl
dbg(draw-map(data))

let build-map(data) = data.split().map(v => v.codepoints())
let map = build-map(data)
dbg(map)

let start 
for (y, row) in enumerate(map) {
  for (x, col) in enumerate(row) {
    if col == "S" {
      start = (x, y)
      break
    }
  }
}
dbg(start: start)

let build-graph(map) = {
  let graph = (:)
  let rows = map.len()
  let cols = map.first().len()
  let is-inside((x, y)) = 0 <= x and x < cols and 0 <= y and y < rows

  let connects-h((a_x, a_y), (b_x, b_y)) = {
    if not is-inside((a_x, a_y)) or not is-inside((b_x, b_y)) { return false }
    let a = map.at(a_y).at(a_x)
    let b = map.at(b_y).at(b_x)
    if a == "." or b == "." { return false }
    if a == "|" or b == "|" { return false }
    if a == "7" or a == "J" { return false }
    if b == "F" or b == "L" { return false }
    return true
  }
  
  let connects-v((a_x, a_y), (b_x, b_y)) = {
    if not is-inside((a_x, a_y)) or not is-inside((b_x, b_y)) { return false }
    let a = map.at(a_y).at(a_x)
    let b = map.at(b_y).at(b_x)
    if a == "." or b == "." { return false }
    if a == "-" or b == "-" { return false }
    if a == "J" or a == "L" { return false }
    if b == "F" or b == "7" { return false }
    return true
  }

  for (y, row) in enumerate(map) {
    for (x, col) in enumerate(row) {
      let p = (x, y)
      let r = (x + 1, y)
      let l = (x - 1, y)
      let d = (x, y + 1)
      let u = (x, y - 1)
      let neighbours = ()
      if connects-h(p, r) { neighbours.push(repr(r)) }
      if connects-h(l, p) { neighbours.push(repr(l)) }
      if connects-v(u, p) { neighbours.push(repr(u)) }
      if connects-v(p, d) { neighbours.push(repr(d)) }
      graph.insert(repr(p), neighbours)
    }
  }
  return graph
}
let graph = build-graph(map)
dbg(graph)
scale(reflow: true, 50%, graph-to-graphviz(graph, engine: "neato"))

let graph = build-graph(build-map(datas.at(4)))
scale(reflow: true, 50%, graph-to-graphviz(graph, engine: "neato"))
```

=== Part Two

You quickly reach the farthest point of the loop, but the animal never emerges.
Maybe its nest is *within the area enclosed by the loop*?

To determine whether it's even worth taking the time to search for such a nest,
you should calculate how many tiles are contained within the loop. For example:

```data
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
```

The above loop encloses merely *four tiles* - the two pairs of `.` in the
southwest and southeast (marked `I` below). The middle `.` tiles (marked `O`
below) are *not* in the loop. Here is the same loop again with those regions
marked:

```data
...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O.....
```

In fact, there doesn't even need to be a full tile path to the outside for
tiles to count as outside the loop - squeezing between pipes is also allowed!
Here, `I` is still within the loop and `O` is still outside the loop:

```data
..........
.S------7.
.|F----7|.
.||OOOO||.
.||OOOO||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........
```

In both of the above examples, *4* tiles are enclosed by the loop.

Here's a larger example:

```data
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
```

The above sketch has many random bits of ground, some of which are in the loop
(`I`) and some of which are outside it (`O`):

```data
OF----7F7F7F7F-7OOOO
O|F--7||||||||FJOOOO
O||OFJ||||||||L7OOOO
FJL7L7LJLJ||LJIL-7OO
L--JOL7IIILJS7F-7L7O
OOOOF-JIIF7FJ|L7L7L7
OOOOL7IF7||L7|IL7L7|
OOOOO|FJLJ|FJ|F7|OLJ
OOOOFJL-7O||O||||OOO
OOOOL---JOLJOLJLJOOO
```

In this larger example, *8* tiles are enclosed by the loop.

Any tile that isn't part of the main loop can count as being enclosed by the
loop. Here's another example with many bits of junk pipe lying around that
aren't connected to the main loop at all:

```data
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
```

Here are just the tiles that are *enclosed by the loop* marked with `I`:

```data
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
```

In this last example, *10* tiles are enclosed by the loop.

Figure out whether you have time to search for the nest by calculating the area
within the loop. *How many tiles are enclosed by the loop*?

=== Resolución

Primero que todo quiero dibujarlo:
```repl
enum(..datas.map(draw-map).map(box))
```

=== Boludeces

Dibujo la data posta:
```repl
scale(reflow: true, 35%, draw-map(read("2023-example2.data")))
```

Es un poco grande.

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
 compose: compose,
 unwrap: unwrap)
```

```repl
dbg(at(0, default: 1)((2, )))
dbg(((1, 2), (2, 3), (1, 4))
      .map(compose(unwrap, op.add, v => v * 2)))
```

= AOC 2024

== Day 1: Historian Hysteria

=== Part One

The *Chief Historian* is always present for the big Christmas sleigh launch,
but nobody has seen him in months! Last anyone heard, he was visiting locations
that are historically significant to the North Pole; a group of Senior
Historians has asked you to accompany them as they check the places they think
he was most likely to visit.

As each location is checked, they will mark it on their list with a _star_.
They figure the Chief Historian *must* be in one of the first fifty places
they'll look, so in order to save Christmas, you need to help them get _fifty
stars_ on their list before Santa takes off on December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each
day in the Advent calendar; the second puzzle is unlocked when you complete the
first. Each puzzle grants _one star_. Good luck!

You haven't even left yet and the group of Elvish Senior Historians has already
hit a problem: their list of locations to check is currently *empty*.
Eventually, someone decides that the best place to check first would be the
Chief Historian's office.

Upon pouring into the office, everyone confirms that the Chief Historian is
indeed nowhere to be found. Instead, the Elves discover an assortment of notes
and lists of historically significant locations! This seems to be the planning
the Chief Historian was doing before he left. Perhaps these notes can be used
to determine which locations to search?

Throughout the Chief's office, the historically significant locations are
listed not by name but by a unique number called the *location ID*. To make
sure they don't miss anything, The Historians split into two groups, each
searching the office and trying to create their own complete list of location
IDs.

There's just one problem: by holding the two lists up *side by side* (your
puzzle input), it quickly becomes clear that the lists aren't very similar.
Maybe you can help The Historians reconcile their lists?

For example:

```data
3   4
4   3
2   5
1   3
3   9
3   3
```

Maybe the lists are only off by a small amount! To find out, pair up the
numbers and measure how far apart they are. Pair up the *smallest number* in
*the left list* with the *smallest number in the right list*, then the
*second-smallest left number* with the *second-smallest right number*, and so
on.

Within each pair, figure out how *far apart* the two numbers are; you'll need
to *add up all of those distances*. For example, if you pair up a `3` from the
left list with a `7` from the right list, the distance apart is `4`; if you
pair up a `9` with a `3`, the distance apart is `6`.

In the example list above, the pairs and distances would be as follows:

- The smallest number in the left list is `1`, and the smallest number in the
  right list is `3`. The distance between them is `2`.
- The second-smallest number in the left list is `2`, and the second-smallest
  number in the right list is another `3`. The distance between them is `1`.
- The third-smallest number in both lists is `3`, so the distance between them
  is `0`.
- The next numbers to pair up are `3` and `4`, a distance of `1`.
- The fifth-smallest numbers in each list are `3` and `5`, a distance of `2`.
- Finally, the largest number in the left list is `4`, while the largest number
  in the right list is `9`; these are a distance `5` apart.

To find the *total distance* between the left list and the right list, add up
the distances between all of the pairs you found. In the example above, this is
`2 + 1 + 0 + 1 + 2 + 5`, a total distance of `11`!

Your actual left and right lists contain many location IDs. *What is the total
distance between your lists?*

==== Resolución

Esto debería ser fácil salvo que sea muy paja cargar los datos:
```repl
let parseado = data.split("\n").map(v => v.split().map(int))
dbg(parseado)
let l1 = parseado.map(v => v.at(0))
let l2 = parseado.map(v => v.at(1))
dbg(l1, l2)
dbg(ordenado: l1.sorted())
dbg(parseado == l1.zip(l2))
```

Oka entonces la función que me piden es:
```definition
let fn(data) = {
  let parseado = (
    data.split("\n")
        .filter(v => v != "")
        .map(v => v.split().map(int)))
  let l1 = parseado.map(v => v.at(0)).sorted()
  let l2 = parseado.map(v => v.at(1)).sorted()
  l1.zip(l2).map(((a, b)) => a - b).map(calc.abs).sum()
}
(aoc-2024-12-01a: fn)
```

```repl
dbg(aoc-2024-12-01a(data))
dbg(aoc-2024-12-01a(read("2024-12-01.data")))
```

== Part Two

Your analysis only confirmed what everyone feared: the two lists of location
IDs are indeed very different.

Or are they?

The Historians can't agree on which group made the mistakes *or* how to read
most of the Chief's handwriting, but in the commotion you notice an interesting
detail: a lot of location IDs appear in both lists! Maybe the other numbers
aren't location IDs at all but rather misinterpreted handwriting.

This time, you'll need to figure out exactly how often each number from the
left list appears in the right list. Calculate a *total similarity* score by
adding up each number in the left list after multiplying it by the number of
times that number appears in the right list.

Here are the same example lists again:

```data
3   4
4   3
2   5
1   3
3   9
3   3
```

For these example lists, here is the process of finding the similarity score:

- The first number in the left list is `3`. It appears in the right list three
  times, so the similarity score increases by `3 * 3 = 9`.
- The second number in the left list is `4`. It appears in the right list once,
  so the similarity score increases by `4 * 1 = 4`.
- The third number in the left list is `2`. It does not appear in the right
  list, so the similarity score does not increase (`2 * 0 = 0`).
- The fourth number, `1`, also does not appear in the right list.
- The fifth number, `3`, appears in the right list three times; the similarity
  score increases by `9`.
- The last number, `3`, appears in the right list three times; the similarity
  score again increases by `9`.

So, for these example lists, the similarity score at the end of this process is
`31` (`9 + 4 + 0 + 0 + 9 + 9`).

Once again consider your left and right lists. *What is their similarity
score?*

=== Resolución

Hacerlo $O(n^2)$ debería entrar ¿No?

```repl
let parseado = (
  data.split("\n")
      .filter(v => v != "")
      .map(v => v.split().map(int)))
let l1 = parseado.map(v => v.at(0))
let l2 = parseado.map(v => v.at(1))
let counts = l1.map(v => l2.filter(v2 => v == v2).len())
dbg(counts, sum: counts.sum())

// Ah no, lo que tengo que hacer es multiplicar los conteos
let point-wise-scores = l1.zip(counts).map(((a, b)) => a * b)
dbg(point-wise-scores, sum: point-wise-scores.sum())
```

Ok, parece que esto funca.

```definition
let fn(data) = {
  let parseado = (
    data.split("\n")
        .filter(v => v != "")
        .map(v => v.split().map(int)))
  let l1 = parseado.map(v => v.at(0))
  let l2 = parseado.map(v => v.at(1))
  l1.map(v => v * l2.filter(v2 => v == v2).len()).sum()
}
(aoc-2024-12-01b: fn)
```

Y los resultados son...
```repl
dbg(aoc-2024-12-01b(data))
dbg(aoc-2024-12-01b(read("2024-12-01.data")))
```

== Resolución con helpers

Ahora que codié el ejercicio vamos a intentar armar una resolución un poco más
linda:

```repl
// Cargo datos
let data = (
  read("2024-12-01.data")
  .split("\n")
  .filter(is_neq(""))
  .map(v => v.split().map(int)))
let l1 = data.map(at(0)).sorted()
let l2 = data.map(at(1)).sorted()
// Part One
dbg(l1.zip(l2).map(compose(unwrap, op.sub, calc.abs)).sum())
// Part Two
dbg(l1.map(v => v * l2.filter(is_eq(v)).len()).sum())
```

Ok, tal vez "linda" no es la palabra adecuada.
