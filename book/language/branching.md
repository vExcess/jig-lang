# Branching

## if, else/if, else
An `if` statement is declared with the following syntax
```ts
if (condition) {
    doStuff();
}
```
`else if` can be chained onto an `if` statment like so
```ts
if (a) {
    doStuff()
} else if (b) {
    doOtherStuff()
}
```
The else if statement will only be evalated and ran if the first if statement's condition evaluates to false. The else statement also works the same except that it doesn't have a condition and therefore is always executed if none of the previous if statements were true
```ts
if (a) {
   println("a is true")
} else if (b) {
   println("a is false and b is true")
} else {
   println("a is false and b is false")
}
```

### No Curly Braces
Sometimes you want to avoid using curly braces for small if statements. In this case you can use a Python-like syntax instead. This opts from using block scoping to indentation scoping.
```ts
// eww
if (cond) {
    foo()
    bar()
}
baz()

// yay
if (cond):
    foo()
    bar()
baz()
```
If the rest of the line after the colon is not whitespace it turns into a single line if statement. In this case the scope lasts until the line break at the end of the line;
```ts
if (cond): foo() bar()
baz()
```

## Switch Statement
Chaining many if statements together can be tedious and messy. Instead use a switch statement. Cases cannot fall through to other branches.
```ts
switch (myValue) {
    -Infinity..-1 => {
        println("myValue is negative")
    },
    0..5, 6, 7, 8, 9 =>
        println("myValue is a single digit"),
    else =>
        println("myValue is a positive number >= 10")
}
```
The switch statement starts at the top case and if the provided value matches matches one of the provided values then the code is executed.
Multiple values can be matched at the same time using a command seperated list. Ranges of values can also be used. In addition switches can return values.
```
println(switch (myValue) {
   'a'..'z' => "lowercase",
   'A'.."Z' => "uppercase
})
```
The end of each branch body must be terminated with a comma unless it is the last branch in which case the comma is optional.