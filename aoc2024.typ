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

==== Part One

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

==== Resolución

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

Con data posta...

```repl
let data = read("2023-example.data")
ejercicio(data)
```

==== Part Two

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

Con data posta...

```repl
let data = read("2023-example.data")
ejercicio-2(data)
```

Hola fran

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

==== Resolución

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

==== Resolución

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

=== Part Two

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

==== Resolución

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

=== Resolución con helpers

Ahora que codié el ejercicio vamos a intentar armar una resolución un poco más
linda:

```repl
// Cargo datos
let data = (
  read("2024-12-01.data")
  .split("\n")
  .filter(is_neq(""))
  .map(compose(call("split"), call("map", int))))
let l1 = data.map(at(0)).sorted()
let l2 = data.map(at(1)).sorted()
// Part One
dbg(l1.zip(l2).map(compose(unwrap, op.sub, calc.abs)).sum())
// Part Two
dbg(l1.map(v => v * l2.filter(is_eq(v)).len()).sum())
```

Ok, tal vez "linda" no es la palabra adecuada.

== Day 2: Red-Nosed Reports

=== Part One

Fortunately, the first location The Historians want to search isn't a long walk
from the Chief Historian's office.

While the Red-Nosed Reindeer nuclear fusion/fission plant appears to contain no
sign of the Chief Historian, the engineers there run up to you as soon as they
see you. Apparently, they *still* talk about the time Rudolph was saved through
molecular synthesis from a single electron.

They're quick to add that - since you're already here - they'd really
appreciate your help analyzing some unusual data from the Red-Nosed reactor.
You turn to check if The Historians are waiting for you, but they seem to have
already divided into groups that are currently searching every corner of the
facility. You offer to help with the unusual data.

The unusual data (your puzzle input) consists of many *reports*, one report per
line. Each report is a list of numbers called *levels* that are separated by
spaces. For example:

```data
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
```

This example data contains six reports each containing five levels.

The engineers are trying to figure out which reports are *safe*. The Red-Nosed
reactor safety systems can only tolerate levels that are either gradually
increasing or gradually decreasing. So, a report only counts as safe if both of
the following are true:

- The levels are either all *increasing* or all *decreasing*.
- Any two adjacent levels differ by *at least one* and *at most three*.

In the example above, the reports can be found safe or unsafe by checking those rules:

- `7 6 4 2 1`: *Safe* because the levels are all decreasing by `1` or `2`.
- `1 2 7 8 9`: *Unsafe* because `2 7` is an increase of `5`.
- `9 7 6 2 1`: *Unsafe* because `6 2` is a decrease of `4`.
- `1 3 2 4 5`: *Unsafe* because `1 3` is increasing but `3 2` is decreasing.
- `8 6 4 4 1`: *Unsafe* because `4 4` is neither an increase or a decrease.
- `1 3 6 7 9`: *Safe* because the levels are all increasing by `1`, `2`, or
  `3`.

So, in this example, `2` reports are safe.

Analyze the unusual data from the engineers. How many reports are safe?

==== Resolución

Tengo que chequear dos condiciones, "sólo en un sentido" y "las diferencias son
chicas".

```repl
let reportes = data.split("\n").map(compose(call("split"), call("map", int)))
dbg(reportes)
let ordenados = reportes.map(call("sorted"))
let solo-en-un-sentido = (
  reportes.zip(ordenados)
    .map(((a, b)) => a == b or a == b.rev()))
dbg(solo-en-un-sentido)
let diferencias-chicas = ordenados.map(v =>
  v.slice(1).zip(v)
   .map(compose(unwrap, op.sub))
   .all(v => 1 <= v and v <= 3))
dbg(diferencias-chicas)
let respuestas = solo-en-un-sentido.zip(diferencias-chicas).map(
  compose(unwrap, op.band))
dbg(respuestas)
let respuesta = respuestas.map(int).sum()
dbg(respuesta)
```

Ok, parece que funca

```definition
let fn(data) = {
  let reportes = (
    data
      .split("\n")
      .filter(is_neq(""))
      .map(compose(call("split"), call("map", int))))
  let ordenados = reportes.map(call("sorted"))
  let solo-en-un-sentido = (
    reportes.zip(ordenados)
      .map(((a, b)) => a == b or a == b.rev()))
  let diferencias-chicas = ordenados.map(v =>
    v.slice(1).zip(v)
     .map(compose(unwrap, op.sub))
     .all(v => 1 <= v and v <= 3))
  let respuestas = solo-en-un-sentido.zip(diferencias-chicas).map(
    compose(unwrap, op.band))
  let respuesta = respuestas.map(int).sum()
  respuesta
}
(aoc-2024-12-02a: fn)
```

```repl
dbg(aoc-2024-12-02a(data))
dbg(aoc-2024-12-02a(read("2024-12-02.data")))
```

=== Part Two

The engineers are surprised by the low number of safe reports until they
realize they forgot to tell you about the Problem Dampener.

The Problem Dampener is a reactor-mounted module that lets the reactor safety
systems tolerate a *single bad level* in what would otherwise be a safe report.
It's like the bad level never happened!

Now, the same rules apply as before, except if removing a single level from an
unsafe report would make it safe, the report instead counts as safe.

More of the above example's reports are now safe:

- `7 6 4 2 1`: *Safe* without removing any level.
- `1 2 7 8 9`: *Unsafe* regardless of which level is removed.
- `9 7 6 2 1`: *Unsafe* regardless of which level is removed.
- `1 3 2 4 5`: *Safe* by removing the second level, `3`.
- `8 6 4 4 1`: *Safe* by removing the third level, 4``.
- `1 3 6 7 9`: *Safe* without removing any level.

Thanks to the Problem Dampener, `4` reports are actually *safe*!

Update your analysis by handling situations where the Problem Dampener can
remove a single level from unsafe reports. *How many reports are now safe*?

==== Resolución

#strike[Ok, medio que puedo reusar el código que ya tengo.] Mucho bardo, vamos
a escribir algo sencillo con un for a lo bestia. La data de prueba era:

```data
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
```

```repl
let reportes = data.split("\n").map(compose(call("split"), call("map", int)))
dbg(reportes)
let pass = 0
for reporte in reportes {
  let es-valido(reporte) = {
    let ordenado = reporte.sorted()
    if reporte == ordenado or reporte == ordenado.rev() {
      let dif = (
        reporte.slice(1)
          .zip(reporte)
          .map(compose(unwrap, op.sub, calc.abs)))
      if dif.all(v => 1 <= v and v <= 3) {
        return true
      }
    }
    return false
  }
  let mostrar(reporte) = "(" + reporte.map(v => [#v]).join(", ") + ")"

  let funca = false
  if es-valido(reporte) {
    [#mostrar(reporte) es válido _de una_ \ ]
    funca = true
  } else {
    for i in range(reporte.len()) {
      let copia = reporte
      let borrado = copia.remove(i)
      if es-valido(copia) {
        copia.insert(i, text(weight: "bold", fill: maroon, str(borrado)))
        [#mostrar(copia) es válido _si le quitás el elemento marcado_ \ ]
        funca = true
        break
      }
    }
  }
  if funca {
    pass = pass + 1
  } else {
    [#mostrar(reporte) *no* es válido  \ ]
  }
}
dbg(pass)
```

Y con la data posta...
```repl
data = read("2024-12-02.data")
let reportes = data.split("\n").slice(0, -1).map(compose(call("split"), call("map", int)))
let pass = 0
for reporte in reportes {
  let es-valido(reporte) = {
    let ordenado = reporte.sorted()
    if reporte == ordenado or reporte == ordenado.rev() {
      let dif = (
        reporte.slice(1)
          .zip(reporte)
          .map(compose(unwrap, op.sub, calc.abs)))
      if dif.all(v => 1 <= v and v <= 3) {
        return true
      }
    }
    return false
  }
  let mostrar(reporte) = "(" + reporte.map(v => [#v]).join(", ") + ")"

  let funca = false
  if es-valido(reporte) {
    [#mostrar(reporte) es válido _de una_ \ ]
    funca = true
  } else {
    for i in range(reporte.len()) {
      let copia = reporte
      let borrado = copia.remove(i)
      if es-valido(copia) {
        copia.insert(i, text(weight: "bold", fill: maroon, str(borrado)))
        [#mostrar(copia) es válido _si le quitás el elemento marcado_ \ ]
        funca = true
        break
      }
    }
  }
  if funca {
    pass = pass + 1
  } else {
    [#mostrar(reporte) *no* es válido \ ]
  }
}
dbg(pass)
```

== Day 3: Mull It Over

=== Part One

"Our computers are having issues, so I have no idea if we have any Chief
Historians in stock! You're welcome to check the warehouse, though," says the
mildly flustered shopkeeper at the North Pole Toboggan Rental Shop. The
Historians head out to take a look.

The shopkeeper turns to you. "Any chance you can see why our computers are
having issues again?"

The computer appears to be trying to run a program, but its memory (your puzzle
input) is *corrupted*. All of the instructions have been jumbled up!

It seems like the goal of the program is just to *multiply some numbers*. It
does that with instructions like `mul(X,Y)`, where `X` and `Y` are each 1-3
digit numbers. For instance, `mul(44,46)` multiplies `44` by `46` to get a
result of `2024`. Similarly, `mul(123,4)` would multiply `123` by `4`.

However, because the program's memory has been corrupted, there are also many
invalid characters that should be *ignored*, even if they look like part of a
`mul` instruction. Sequences like `mul(4*`, `mul(6,9!`, `?(12,34)`, or
`mul ( 2 , 4 )` do *nothing*.

For example, consider the following section of corrupted memory:

```data
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))`
```

Only the four highlighted sections are real mul instructions. Adding up the
result of each instruction produces `161` `(2*4 + 5*5 + 11*8 + 8*5)`.

Scan the corrupted memory for uncorrupted mul instructions. *What do you get if
you add up all of the results of the multiplications?*

==== Resolución

```repl
data.matches(regex("mul\((\d+),(\d+)\)")).map(compose(
  field("captures"),
  call("map", int),
  unwrap,
  op.mul
)).sum()
```

Ok, y con la data posta...
```repl
read("2024-12-03.data").matches(regex("mul\((\d+),(\d+)\)")).map(compose(
  field("captures"),
  call("map", int),
  unwrap,
  op.mul
)).sum()
```

=== Part Two

As you scan through the corrupted memory, you notice that some of the
conditional statements are also still intact. If you handle some of the
uncorrupted conditional statements in the program, you might be able to get an
even more accurate result.

There are two new instructions you'll need to handle:

- The `do()` instruction *enables* future mul instructions.
- The `don't()` instruction *disables* future mul instructions.

Only the *most recent* `do()` or `don't()` instruction applies. At the
beginning of the program, `mul` instructions are *enabled*.

For example:

```data
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
```

This corrupted memory is similar to the example from before, but this time the
`mul(5,5)` and `mul(11,8)` instructions are *disabled* because there is a
`don't()` instruction before them. The other `mul` instructions function
normally, including the one at the end that gets re-*enabled* by a `do()`
instruction.

This time, the sum of the results is *48* `(2*4 + 8*5)`.

Handle the new instructions; *what do you get if you add up all of the results
of just the enabled multiplications?*

==== Resolución

```repl
(read("2024-12-03.data")
  .matches(regex("mul\((\d+),(\d+)\)|do\(\)|don't\(\)"))
  .fold((apply: true, value: 0), (state, v) =>
    if v.text == "do()" {
      (apply: true, value: state.value)
    } else if v.text == "don't()" {
      (apply: false, value: state.value)
    } else if state.apply {
      let (a, b) = v.captures
      (apply: true, value: state.value + int(a) * int(b))
    } else {
      state
    }))
```

== Day 4: Ceres Search

=== Part One

"Looks like the Chief's not here. Next!" One of The Historians pulls out a
device and pushes the only button on it. After a brief flash, you recognize the
interior of the Ceres monitoring station!

As the search for the Chief continues, a small Elf who lives on the station
tugs on your shirt; she'd like to know if you could help her with her *word
search* (your puzzle input). She only has to find one word: `XMAS`.

This word search allows words to be horizontal, vertical, diagonal, written
backwards, or even overlapping other words. It's a little unusual, though, as
you don't merely need to find one instance of `XMAS` - you need to find *all of
them*. Here are a few ways `XMAS` might appear, where irrelevant characters
have been replaced with .:

```
..X...
.SAMX.
.A..A.
XMAS.S
.X....
```

The actual word search will be full of letters instead. For example:

```data
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
```

In this word search, `XMAS` occurs a total of *18* times; here's the same word
search again, but where letters not involved in any `XMAS` have been replaced
with `.`:

```
....XXMAS.
.SAMXMS...
...S..A...
..A.A.MS.X
XMASAMX.MM
X.....XA.A
S.S.S.S.SS
.A.A.A.A.A
..M.M.M.MM
.X.X.XMASX
```

Take a look at the little Elf's word search. *How many times does `XMAS`
appear?*

==== Resolucion

Esto creo que debería ser fácil

```repl
let map = data.split("\n").filter(is_neq("")).map(call("codepoints"))
dbg(map)

let get(map, x, y) = {
  if 0 <= y and y < map.len() {
    let row = map.at(y)
    if 0 <= x and x < row.len() {
      return row.at(x)
    }
  }
}
dbg(
  origin: get(map, 0, 0),
  corner: get(map, 9, 9),
  outside: (
    get(map, -1, 0),
    get(map, 0, -1),
    get(map, 99, 0),
    get(map, 0, 99)))

let está-xmas(map, x, y, dx, dy) = {
  for c in "XMAS" {
    if get(map, x, y) != c {
      return false
    }
    x = x + dx
    y = y + dy
  }
  return true
}

let count = 0
for (y, row) in enumerate(map) {
  for x in range(row.len()) {
    for dx in (-1, 0, 1) {
      for dy in (-1, 0, 1) {
        if dx == 0 and dy == 0 {
          continue
        }
        if (está-xmas(map, x, y, dx, dy)) {
          dbg(x: x, y: y, dx: dx, dy: dy)
          count = count + 1
        }
      }
    }
  }
}
dbg(count: count)

dbg({
  import "@preview/cetz:0.3.0"
  cetz.canvas({
    import cetz.draw: *
    set-style(mark: (end: ">"))

    for (y, row) in enumerate(map) {
      for x in range(row.len()) {
        let did-match-color = black
        for dx in (-1, 0, 1) {
          for dy in (-1, 0, 1) {
            if dx == 0 and dy == 0 {
              continue
            }
            if (está-xmas(map, x, y, dx, dy)) {
              let small = 0.9
              let small-dx = small * dx
              let small-dy = small * dy
              circle((x, y), radius: 0.2, fill: black)
              line((x, y), (x + small-dx, y + small-dy))
              did-match-color = white
            } else {
            }
          }
        }
        content((x, y), text(fill: did-match-color, get(map, x, y)))
      }
    }
  })
})
```

Ok, parece que funca!!!

```repl
let map = (
  read("2024-12-04.data")
    .split("\n")
    .filter(is_neq("")).map(call("codepoints")))

let get(map, x, y) = {
  if 0 <= y and y < map.len() {
    let row = map.at(y)
    if 0 <= x and x < row.len() {
      return row.at(x)
    }
  }
}

let está-xmas(map, x, y, dx, dy) = {
  for c in "XMAS" {
    if get(map, x, y) != c {
      return false
    }
    x = x + dx
    y = y + dy
  }
  return true
}

let count = 0
for (y, row) in enumerate(map) {
  for x in range(row.len()) {
    for dx in (-1, 0, 1) {
      for dy in (-1, 0, 1) {
        if dx == 0 and dy == 0 {
          continue
        }
        if (está-xmas(map, x, y, dx, dy)) {
          count = count + 1
        }
      }
    }
  }
}
dbg(count: count)
```

=== Part Two

The Elf looks quizzically at you. Did you misunderstand the assignment?

Looking for the instructions, you flip over the word search to find that this
isn't actually an `XMAS` puzzle; it's an `X-MAS` puzzle in which you're
supposed to find two `MAS` in the shape of an `X`. One way to achieve that is
like this:

```
M.S
.A.
M.S
```

Irrelevant characters have again been replaced with `.` in the above diagram.
Within the `X`, each `MAS` can be written forwards or backwards.

Here's the same example from before, but this time all of the `X-MAS`es have
been kept instead:

```data
.M.S......
..A..MSMS.
.M.S.MAA..
..A.ASMSM.
.M.S.M....
..........
S.S.S.S.S.
.A.A.A.A..
M.M.M.M.M.
..........
```

In this example, an `X-MAS` appears *9* times.

Flip the word search from the instructions back over to the word search side
and try again. *How many times does an `X-MAS` appear?*

==== Resolución

Uf, medio paja de codear así a lo bestia pero bueno...


```repl
let map = data.split("\n").filter(is_neq("")).map(call("codepoints"))

let get(map, x, y) = {
  if 0 <= y and y < map.len() {
    let row = map.at(y)
    if 0 <= x and x < row.len() {
      return row.at(x)
    }
  }
}

let está-x-mas(map, x, y, flip-l, flip-r) = {
  for (i, c) in "MAS".codepoints().enumerate() {
    let l = if flip-l {
      get(map, x + 2 - i, y + 2 - i)
    } else {
      get(map, x + i, y + i)
    }
    let r = if flip-r {
      get(map, x + i, y + 2 - i)
    } else {
      get(map, x + 2 - i, y + i)
    }
    if l != c or r != c {
      return false
    }
  }
  return true
}

let count = 0
for (y, row) in enumerate(map) {
  for x in range(row.len()) {
    for flip-l in (false, true) {
      for flip-r in (false, true) {
        if está-x-mas(map, x, y, flip-l, flip-r) {
          dbg(x: x, y: y, flip-l: flip-l, flip-r: flip-r)
          count = count + 1
        }
      }
    }
  }
}
dbg(count: count)

dbg({
  import "@preview/cetz:0.3.0"
  cetz.canvas({
    import cetz.draw: *
    set-style(mark: (end: ">"))

    for (y, row) in enumerate(map) {
      for x in range(row.len()) {
        let did-match-color = maroon
        for flip-l in (false, true) {
          for flip-r in (false, true) {
            if está-x-mas(map, x, y, flip-l, flip-r) {
              if flip-l {
                line(stroke: gray, (x + 2, y + 2), (x + 0.1, y + 0.1))
              } else {
                line(stroke: gray, (x, y), (x + 1.9, y + 1.9))
              }
              if flip-r {
                line(stroke: gray, (x + 1, y + 1), (x + 1.9, y + 0.1))
              } else {
                line(stroke: gray, (x + 1, y + 1), (x + 0.1, y + 1.9))
              }
              circle((x, y), radius: 0.2, fill: black)
              did-match-color = white
            }
          }
        }
        content((x, y), text(weight: "bold", fill: did-match-color, get(map, x, y)))
      }
    }
  })
})
```

Ok, y con la data posta...
```repl
let map = (
  read("2024-12-04.data")
    .split("\n")
    .filter(is_neq("")).map(call("codepoints")))

let get(map, x, y) = {
  if 0 <= y and y < map.len() {
    let row = map.at(y)
    if 0 <= x and x < row.len() {
      return row.at(x)
    }
  }
}

let está-x-mas(map, x, y, flip-l, flip-r) = {
  for (i, c) in "MAS".codepoints().enumerate() {
    let l = if flip-l {
      get(map, x + 2 - i, y + 2 - i)
    } else {
      get(map, x + i, y + i)
    }
    let r = if flip-r {
      get(map, x + i, y + 2 - i)
    } else {
      get(map, x + 2 - i, y + i)
    }
    if l != c or r != c {
      return false
    }
  }
  return true
}

let count = 0
for (y, row) in enumerate(map) {
  for x in range(row.len()) {
    for flip-l in (false, true) {
      for flip-r in (false, true) {
        if está-x-mas(map, x, y, flip-l, flip-r) {
          count = count + 1
        }
      }
    }
  }
}
dbg(count: count)
```

==== Visualización

Agus me dio una idea piola para visualizar la solución:

```data
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
```

```repl
let map = data.split("\n").filter(is_neq("")).map(call("codepoints"))

let get(map, x, y) = {
  if 0 <= y and y < map.len() {
    let row = map.at(y)
    if 0 <= x and x < row.len() {
      return row.at(x)
    }
  }
}

let está-x-mas(map, x, y, flip-l, flip-r) = {
  for (i, c) in "MAS".codepoints().enumerate() {
    let l = if flip-l {
      get(map, x + 1 - i, y + 1 - i)
    } else {
      get(map, x - 1 + i, y - 1 + i)
    }
    let r = if flip-r {
      get(map, x - 1 + i, y + 1 - i)
    } else {
      get(map, x + 1 - i, y - 1 + i)
    }
    if l != c or r != c {
      return false
    }
  }
  return true
}

import "@preview/cetz:0.3.0"
cetz.canvas({
  import cetz.draw: *
  set-style(mark: (end: ">"))

  for (y, row) in enumerate(map) {
    for x in range(row.len()) {
      let did-match = false
      for flip-l in (false, true) {
        for flip-r in (false, true) {
          if está-x-mas(map, x, y, flip-l, flip-r) {
            if flip-l {
              line((x + 0.5, y + 0.5), (x - 0.5, y - 0.5))
            } else {
              line((x - 0.5, y - 0.5), (x + 0.5, y + 0.5))
            }
            if flip-r {
              line((x - 0.5, y + 0.5), (x + 0.5, y - 0.5))
            } else {
              line((x + 0.5, y - 0.5), (x - 0.5, y + 0.5))
            }
            did-match = true
          }
        }
      }
      if did-match {
        circle((x, y), radius: 0.2, fill: black)
        content((x, y), text(fill: white, get(map, x, y)))
      } else {
        content((x, y), text(fill: black, get(map, x, y)))
      }
    }
  }
})
```

== Day 5: Print Queue

=== Part One

Satisfied with their search on Ceres, the squadron of scholars suggests
subsequently scanning the stationery stacks of sub-basement 17.

The North Pole printing department is busier than ever this close to Christmas,
and while The Historians continue their search of this historically significant
facility, an Elf operating a very familiar printer beckons you over.

The Elf must recognize you, because they waste no time explaining that the new
*sleigh launch safety manual* updates won't print correctly. Failure to update
the safety manuals would be dire indeed, so you offer your services.

Safety protocols clearly indicate that new pages for the safety manuals must be
printed in a *very specific order*. The notation `X|Y` means that if both page
number `X` and page number `Y` are to be produced as part of an update, page number
`X` *must* be printed at some point before page number `Y`.

The Elf has for you both the *page ordering rules* and the *pages to produce in
each update* (your puzzle input), but can't figure out whether each update has
the pages in the right order.

For example:

```data
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
```

The first section specifies the *page ordering rules*, one per line. The first
rule, `47|53`, means that if an update includes both page number `47` and page
number `53`, then page number `47` *must* be printed at some point before page
number `53`. (`47` doesn't necessarily need to be *immediately* before `53`;
other pages are allowed to be between them.)

The second section specifies the page numbers of each *update*. Because most
safety manuals are different, the pages needed in the updates are different
too. The first update, `75,47,61,53,29`, means that the update consists of page
numbers 75, 47, 61, 53, and 29.

To get the printers going as soon as possible, start by identifying *which
updates are already in the right order*.

In the above example, the first update `(75,47,61,53,29)` is in the right
order:

- `75` is correctly first because there are rules that put each other page
  after it: `75|47`, `75|61`, `75|53`, and `75|29`.
- `47` is correctly second because `75` must be before it (`75|47`) and every
  other page must be after it according to `47|61`, `47|53`, and `47|29`.
- `61` is correctly in the middle because 75 and 47 are before it (`75|61` and
  `47|61`) and 53 and 29 are after it (`61|53` and `61|29`).
- `53` is correctly fourth because it is before page number 29 (`53|29`).
- `29` is the only page left and so is correctly last.

Because the first update does not include some page numbers, the ordering rules
involving those missing page numbers are ignored.

The second and third updates are also in the correct order according to the
rules. Like the first update, they also do not include every page number, and
so only some of the ordering rules apply - within each update, the ordering
rules that involve missing page numbers are not used.

The fourth update, `75,97,47,61,53`, is *not* in the correct order: it would
print 75 before 97, which violates the rule `97|75`.

The fifth update, `61,13,29`, is also *not* in the correct order, since it
breaks the rule `29|13`.

The last update, `97,13,75,29,47`, is *not* in the correct order due to
breaking several rules.

For some reason, the Elves also need to know the *middle page number* of each
update being printed. Because you are currently only printing the
correctly-ordered updates, you will need to find the middle page number of each
correctly-ordered update. In the above example, the correctly-ordered updates
are:

```
75,47,61,53,29
97,61,53,29,13
75,29,13
```

These have middle page numbers of `61`, `53`, and `29` respectively. Adding
these page numbers together gives `143`.

Of course, you'll need to be careful: the actual list of *page ordering rules*
is bigger and more complicated than the above example.

Determine which updates are already in the correct order. *What do you get if
you add up the middle page number from those correctly-ordered updates?*

==== Resolución

```repl
let (rules,pages) = data.split("\n\n")
let rules = rules.split("\n").map(call("split", "|"))
let pages = pages.split("\n").map(call("split", ","))
let rules-graph = (:)
for (from, to) in rules {
  if rules-graph.at(from, default: none) == none {
    rules-graph.insert(from, ())
  }
  rules-graph.at(from).push(to)
}
dbg(rules)
dbg(rules-graph)
dbg(graph-to-graphviz(rules-graph))
dbg(pages)
```

Mmmm a ver la forma del grafo que me pasan
```repl
let (rules,pages) = read("2024-12-05.data").split("\n\n")
let rules = rules.split("\n").map(call("split", "|"))
let pages = pages.split("\n").slice(0, -1).map(call("split", ","))
let rules-graph = (:)
for (from, to) in rules {
  if rules-graph.at(from, default: none) == none {
    rules-graph.insert(from, ())
  }
  rules-graph.at(from).push(to)
}
dbg(cantidad-de-outputs: rules.len(), cantidad-de-paginas: rules-graph.len())
// El plugin crashea :(
//dbg(graph-to-graphviz(rules-graph))
```

Me piden un toposort, en el grafo grande hay pocos vértices así que no debería
ser tan grave hacer algo sencillo.

```repl
// Parse input
let (rules,pages) = data.split("\n\n")
let rules = rules.split("\n").map(call("split", "|"))
let pages = pages.split("\n").filter(is_neq("")).map(call("split", ","))

// Build graph
let rules-graph = (:)
for (from, to) in rules {
  if rules-graph.at(from, default: none) == none {
    rules-graph.insert(from, ())
  }
  rules-graph.at(from).push(to)
}

let build-subgraph(nodes) = (
  nodes
    .map(k => (k, rules-graph.at(k, default: ()).filter(v => v in nodes)))
    .to-dict()
)

let is-valid(update, subgraph) = {
  let state = (:)
  for page in update.rev() {
    if state.at(page, default: false) {
      return false
    }
    state.insert(page, true)
    for n in subgraph.at(page, default: ()) {
      if not state.at(n, default: false) {
        return false
      }
    }
  }

  return true
}

for update in pages {
  let subgraph = build-subgraph(update)
  dbg(subgraph)
  dbg(update: update, valid: is-valid(update, subgraph), graph: graph-to-graphviz(subgraph))
}

dbg(answer: pages.filter(update => is-valid(update, build-subgraph(update)))
                 .map(update => update.at(update.len().bit-rshift(1)))
                 .map(int)
                 .sum())
```

Medio paja, pero parece que funca, a ver con los datos posta
```repl
// Parse input
let (rules,pages) = read("2024-12-05.data").split("\n\n")
let rules = rules.split("\n").map(call("split", "|"))
let pages = pages.split("\n").filter(is_neq("")).map(call("split", ","))

// Build graph
let rules-graph = (:)
for (from, to) in rules {
  if rules-graph.at(from, default: none) == none {
    rules-graph.insert(from, ())
  }
  rules-graph.at(from).push(to)
}

let build-subgraph(nodes) = (
  nodes
    .map(k => (k, rules-graph.at(k, default: ()).filter(v => v in nodes)))
    .to-dict()
)

let is-valid(update, subgraph) = {
  let state = (:)
  for page in update.rev() {
    if state.at(page, default: false) {
      return false
    }
    state.insert(page, true)
    for n in subgraph.at(page, default: ()) {
      if not state.at(n, default: false) {
        return false
      }
    }
  }

  return true
}

dbg(answer: pages.filter(update => is-valid(update, build-subgraph(update)))
                 .map(update => update.at(update.len().bit-rshift(1)))
                 .map(int)
                 .sum())
```

=== Part Two

While the Elves get to work printing the correctly-ordered updates, you have a
little time to fix the rest of them.

For each of the *incorrectly-ordered updates*, use the page ordering rules to
put the page numbers in the right order. For the above example, here are the
three incorrectly-ordered updates and their correct orderings:

- `75,97,47,61,53` becomes `97,75,47,61,53`.
- `61,13,29` becomes `61,29,13`.
- `97,13,75,29,47` becomes `97,75,47,29,13`.

After taking *only the incorrectly-ordered updates* and ordering them
correctly, their middle page numbers are `47`, `29`, and `47`. Adding these
together produces `123`.

Find the updates which are not in the correct order. *What do you get if you add
up the middle page numbers after correctly ordering just those updates?*

==== Resolución

```data
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
```

```repl
// Parse input
let (rules,pages) = data.split("\n\n")
let rules = rules.split("\n").map(call("split", "|"))
let pages = pages.split("\n").filter(is_neq("")).map(call("split", ","))

// Build graph
let rules-graph = (:)
for (from, to) in rules {
  if rules-graph.at(from, default: none) == none {
    rules-graph.insert(from, ())
  }
  rules-graph.at(from).push(to)
}

let build-subgraph(nodes) = (
  nodes
    .map(k => (k, rules-graph.at(k, default: ()).filter(v => v in nodes)))
    .to-dict()
)

let is-valid(update, subgraph) = {
  let state = (:)
  for page in update.rev() {
    if state.at(page, default: false) {
      return false
    }
    state.insert(page, true)
    for n in subgraph.at(page, default: ()) {
      if not state.at(n, default: false) {
        return false
      }
    }
  }

  return true
}

let do-toposort(subgraph) = {
  let toposort = ()
  let state = (:)
  for v in subgraph.keys() {
    let stack = ((node: v, idx: 0),)
    while stack.len() != 0 {
      let frame = stack.pop()
      let neighbours = subgraph.at(frame.node, default: ())
      if frame.idx == 0 {
        // FN ENTRY
        if state.at(frame.node, default: false) {
          continue
        }
        state.insert(frame.node, "FOUND-LOOP")
      }
      if frame.idx == neighbours.len() {
        state.insert(frame.node, true)
        toposort.push(frame.node)
        continue
      }
      let new-frame = (node: neighbours.at(frame.idx), idx: 0)
      frame.idx = frame.idx + 1
      stack.push(frame)
      stack.push(new-frame)
    }
  }
  return toposort.rev()
}

let answer = 0
for update in pages {
  let subgraph = build-subgraph(update)
  if is-valid(update, subgraph) {
    continue
  }
  let toposort = do-toposort(subgraph)
  answer = answer + int(toposort.at(toposort.len().bit-rshift(1)))
  dbg(update, toposort)
}
dbg(answer: answer)
```

Bueno, parece que mi emulador de pila funca (es horrible) a ver con la data
posta...

```repl
// Parse input
let (rules,pages) = read("2024-12-05.data").split("\n\n")
let rules = rules.split("\n").map(call("split", "|"))
let pages = pages.split("\n").filter(is_neq("")).map(call("split", ","))

// Build graph
let rules-graph = (:)
for (from, to) in rules {
  if rules-graph.at(from, default: none) == none {
    rules-graph.insert(from, ())
  }
  rules-graph.at(from).push(to)
}

let build-subgraph(nodes) = (
  nodes
    .map(k => (k, rules-graph.at(k, default: ()).filter(v => v in nodes)))
    .to-dict()
)

let is-valid(update, subgraph) = {
  let state = (:)
  for page in update.rev() {
    if state.at(page, default: false) {
      return false
    }
    state.insert(page, true)
    for n in subgraph.at(page, default: ()) {
      if not state.at(n, default: false) {
        return false
      }
    }
  }

  return true
}

let do-toposort(subgraph) = {
  let toposort = ()
  let state = (:)
  for v in subgraph.keys() {
    let stack = ((node: v, idx: 0),)
    while stack.len() != 0 {
      let frame = stack.pop()
      let neighbours = subgraph.at(frame.node, default: ())
      if frame.idx == 0 {
        // FN ENTRY
        if state.at(frame.node, default: false) {
          continue
        }
        state.insert(frame.node, "FOUND-LOOP")
      }
      if frame.idx == neighbours.len() {
        state.insert(frame.node, true)
        toposort.push(frame.node)
        continue
      }
      let new-frame = (node: neighbours.at(frame.idx), idx: 0)
      frame.idx = frame.idx + 1
      stack.push(frame)
      stack.push(new-frame)
    }
  }
  return toposort.rev()
}

dbg(pages.map(update => {
  let subgraph = build-subgraph(update)
  if is-valid(update, subgraph) {
    return 0
  }
  let toposort = do-toposort(subgraph)
  return int(toposort.at(toposort.len().bit-rshift(1)))
}).sum())
```

== Day 6: Guard Gallivant

=== Part One

The Historians use their fancy device again, this time to whisk you all away to
the North Pole prototype suit manufacturing lab... in the year 1518! It turns
out that having direct access to history is very convenient for a group of
historians.

You still have to be careful of time paradoxes, and so it will be important to
avoid anyone from 1518 while The Historians search for the Chief.
Unfortunately, a single *guard* is patrolling this part of the lab.

Maybe you can work out where the guard will go ahead of time so that The
Historians can search safely?

You start by making a map (your puzzle input) of the situation. For example:

```data
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
```

The map shows the current position of the guard with `^` (to indicate the guard
is currently facing *up* from the perspective of the map). Any *obstructions* -
crates, desks, alchemical reactors, etc. - are shown as `#`.

Lab guards in 1518 follow a very strict patrol protocol which involves
repeatedly following these steps:

- If there is something directly in front of you, turn right 90 degrees.
- Otherwise, take a step forward.

Following the above protocol, the guard moves up several times until she
reaches an obstacle (in this case, a pile of failed suit prototypes):

```
....#.....
....^....#
..........
..#.......
.......#..
..........
.#........
........#.
#.........
......#...
```

Because there is now an obstacle in front of the guard, she turns right before
continuing straight in her new facing direction:

```
....#.....
........>#
..........
..#.......
.......#..
..........
.#........
........#.
#.........
......#...
```

Reaching another obstacle (a spool of several *very* long polymers), she turns
right again and continues downward:

```
....#.....
.........#
..........
..#.......
.......#..
..........
.#......v.
........#.
#.........
......#...
```

This process continues for a while, but the guard eventually leaves the mapped
area (after walking past a tank of universal solvent):

```
....#.....
.........#
..........
..#.......
.......#..
..........
.#........
........#.
#.........
......#v..
```

By predicting the guard's route, you can determine which specific positions in
the lab will be in the patrol path. *Including the guard's starting position*,
the positions visited by the guard before leaving the area are marked with an
X:

```
....#.....
....XXXXX#
....X...X.
..#.X...X.
..XXXXX#X.
..X.X.X.X.
.#XXXXXXX.
.XXXXXXX#.
#XXXXXXX..
......#X..
```

In this example, the guard will visit *`41`* distinct positions on your map.

Predict the path of the guard. *How many distinct positions will the guard visit
before leaving the mapped area?*    

==== Resolución

¿Funca hacerlo iterativo?

```repl
let map = data.split("\n").filter(is_neq("")).map(call("codepoints"))
dbg(map)

let start-pos = none
for (y, row) in map.enumerate() {
  for (x, cell) in row.enumerate() {
    if cell in "^" {
      start-pos = (x: x, y: y)
      break
    }
  }
  if start-pos != none {
    break
  }
}
dbg(start)

let next-dir = (
  "^": ">",
  ">": "v",
  "v": "<",
  "<": "^",
)
let dx = (
  "^": 0,
  ">": 1,
  "v": 0,
  "<": -1,
)
let dy = (
  "^": -1,
  ">": 0,
  "v": 1,
  "<": 0,
)

let rows = map.len()
let cols = map.first().len()
let inside((x, y)) = (
  0 <= x and x < cols
  and 0 <= y and y < rows
)

let cur-dir = "^"
let pos = start-pos
while true {
  let next-pos = (x: pos.x + dx.at(cur-dir), y: pos.y + dy.at(cur-dir))
  dbg(pos: pos, inside: inside(next-pos), size: (cols, rows))
  if not inside(next-pos) {
    break
  }

  let next-c = map.at(next-pos.y).at(next-pos.x)
  if next-c == "#" {
    cur-dir = next-dir.at(cur-dir)
  } else {
    pos = next-pos
    map.at(pos.y).at(pos.x) = "X"
  }
}
dbg(map)

// Cuento las X
let ocupadas = 0
for (y, row) in map.enumerate() {
  for (x, cell) in row.enumerate() {
    if cell in "^X^" {
      ocupadas = ocupadas + 1
    }
  }
}
dbg(answer: ocupadas)

dbg("Ok, y si dibujo el camino?")
dbg({
  import "@preview/cetz:0.3.0"
  cetz.canvas({
    import cetz.draw: *
    set-style(mark: (end: ">"))

    let ocupadas = 0
    for (y, row) in map.enumerate() {
      for (x, cell) in row.enumerate() {
        if cell == "#" {
	  rect((x - 0.7, y - 0.7), (x + 0.7, y + 0.7), fill: gray)
	}
      }
    }

    let cur-dir = "^"
    let pos = start-pos
    while true {
      let next-pos = (x: pos.x + dx.at(cur-dir), y: pos.y + dy.at(cur-dir))
      if not inside(next-pos) {
        break
      }
    
      let next-c = map.at(next-pos.y).at(next-pos.x)
      if next-c == "#" {
        cur-dir = next-dir.at(cur-dir)
      } else {
	line((pos.x, pos.y), (next-pos.x, next-pos.y))
        pos = next-pos
      }
    }

    // https://math.stackexchange.com/a/1344707
    line(
      (start-pos.x - 0.2, start-pos.y + 0.4 / calc.sqrt(12)),
      (start-pos.x + 0.2, start-pos.y + 0.4 / calc.sqrt(12)),
      (start-pos.x,       start-pos.y - 0.4 / calc.sqrt(3)),
      mark: none,
      close: true,
      fill: gray
    )
  })
})
```

A ver si la data posta es suficientemente chica...
```repl
let map = read("2024-12-06.data").split("\n").filter(is_neq("")).map(call("codepoints"))

let start-pos = none
for (y, row) in map.enumerate() {
  for (x, cell) in row.enumerate() {
    if cell in "^" {
      start-pos = (x: x, y: y)
      break
    }
  }
  if start-pos != none {
    break
  }
}

let next-dir = (
  "^": ">",
  ">": "v",
  "v": "<",
  "<": "^",
)
let dx = (
  "^": 0,
  ">": 1,
  "v": 0,
  "<": -1,
)
let dy = (
  "^": -1,
  ">": 0,
  "v": 1,
  "<": 0,
)

let rows = map.len()
let cols = map.first().len()
let inside((x, y)) = (
  0 <= x and x < cols
  and 0 <= y and y < rows
)

let cur-dir = "^"
let pos = start-pos
while true {
  let next-pos = (x: pos.x + dx.at(cur-dir), y: pos.y + dy.at(cur-dir))
  if not inside(next-pos) {
    break
  }

  let next-c = map.at(next-pos.y).at(next-pos.x)
  if next-c == "#" {
    cur-dir = next-dir.at(cur-dir)
  } else {
    pos = next-pos
    map.at(pos.y).at(pos.x) = "X"
  }
}

// Cuento las X
let ocupadas = 0
for (y, row) in map.enumerate() {
  for (x, cell) in row.enumerate() {
    if cell in "^X^" {
      ocupadas = ocupadas + 1
    }
  }
}
dbg(answer: ocupadas)
```

=== Part Two

While The Historians begin working around the guard's patrol route, you borrow
their fancy device and step outside the lab. From the safety of a supply
closet, you time travel through the last few months and record the nightly
status of the lab's guard post on the walls of the closet.

Returning after what seems like only a few seconds to The Historians, they
explain that the guard's patrol area is simply too large for them to safely
search the lab without getting caught.

Fortunately, they are *pretty sure* that adding a single new obstruction
*won't* cause a time paradox. They'd like to place the new obstruction in such
a way that the guard will get *stuck in a loop*, making the rest of the lab
safe to search.

To have the lowest chance of creating a time paradox, The Historians would like
to know *all* of the possible positions for such an obstruction. The new
obstruction can't be placed at the guard's starting position - the guard is
there right now and would notice.

In the above example, there are only `6` different positions where a new
obstruction would cause the guard to get stuck in a loop. The diagrams of these
six situations use `O` to mark the new obstruction, `|` to show a position
where the guard moves up/down, `-` to show a position where the guard moves
left/right, and `+` to show a position where the guard moves both up/down and
left/right.

Option one, put a printing press next to the guard's starting position:

```
....#.....
....+---+#
....|...|.
..#.|...|.
....|..#|.
....|...|.
.#.O^---+.
........#.
#.........
......#...
```

Option two, put a stack of failed suit prototypes in the bottom right quadrant
of the mapped area:

```
....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
......O.#.
#.........
......#...
```

Option three, put a crate of chimney-squeeze prototype fabric next to the
standing desk in the bottom right quadrant:

```
....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
.+----+O#.
#+----+...
......#...
```

Option four, put an alchemical retroencabulator near the bottom left corner:

```
....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
..|...|.#.
#O+---+...
......#...
```

Option five, put the alchemical retroencabulator a bit to the right instead:

```
....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
....|.|.#.
#..O+-+...
......#...
```

Option six, put a tank of sovereign glue right next to the tank of universal
solvent:

```
....#.....
....+---+#
....|...|.
..#.|...|.
..+-+-+#|.
..|.|.|.|.
.#+-^-+-+.
.+----++#.
#+----++..
......#O..
```

It doesn't really matter what you choose to use as an obstacle so long as you
and The Historians can put it into position without the guard noticing. The
important thing is having enough options that you can find one that minimizes
time paradoxes, and in this example, there are *`6`* different positions you
could choose.

You need to get the guard stuck in a loop by adding a single new obstruction.
*How many different positions could you choose for this obstruction?*
