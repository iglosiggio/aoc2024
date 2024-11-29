#let small(body) = context {
  text(size: text.size * 0.8, body)
}
#set page(
  paper: "a4",
  numbering: "1",
)
#set text(lang: "es")
#set par(justify: true)

#let dbg(body) = [#body]
#let code(body) = raw(lang: "typc", body)

#let globals = state("globals", (dbg: dbg))

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

#show raw.where(lang: "definition"): it => {
  block(..label-options, [*Code*])
  block(..body-options, raw(lang: "typc", it.text))
  globals.update(currentGlobals => {
    (: ..currentGlobals, ..eval(scope: currentGlobals, it.text))
  })
}

#show raw.where(lang: "repl"): it => context {
  block(..label-options, [*Code*])
  block(..body-options, raw(lang: "typc", it.text))
  block(..label-options, [*Result*])
  block(..body-options, [#eval(scope: globals.get(), it.text)])
}

#show raw.where(lang: "data"): it => {
  raw(it.text)
  globals.update(currentGlobals => (: ..currentGlobals, data: it.text))
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
