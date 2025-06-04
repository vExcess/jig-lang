# Loops

## While Loops
A while loop continues until the condition is met. They are declared like so
```ts
var i = 0;
while (i < 10) {
    i++;
}
```
A variation of the while loop is the do/while loop. The difference is that the do block is executed once before the condition is evalated compared to a normal while loop where the body is executed only after the condition has been evaluated.
```ts
var i = 0;
do {
    stuff();
    i++;
} while (i < 10);
```
is functionally equivelant to
```ts
var i = 0;
stuff();
i++;
while (i < 10) {
    stuff();
    i++;
}
```
You can opt into using indentation scoping instead of block scoping like
```ts
// this
while (i < 10):
    i++;

// or this
while (i < 10): i++

// or this
do:
    stuff();
    i++;
while (i < 10);
```
These follow the same rules as mentioned in the branching section of the book.

## For Loops
A for loop is just syntactical sugar for a while loop written with the following syntax `for (initializations; condition; updateExpression)`

- initializations is executed (one time) before the execution of the loop body.  
- condition defines the condition for executing the code block.  
- updateExpression is executed (every time) after the code block has been executed.

Each expression can be left blank like so `for (;;)` however if expression 2 is left blank then it always evaluates to false resulting in an infinite loop
```ts
// Multiple variables can be declared in a single expression
for (var i = 0, j = 10; i < j; i++) {
    doStuff();
}
// the above for loop is functionally equivelant to the following while loop
{
    var i = 0, j = 10;
    while (i < j) {
        doStuff();
        i++;
    }
}
```
Some more syntactical sugar is the `for in` loop
```ts
for (var prop in thing) {
    println(prop);
}
// if thing is an Array then the above for in loop is functionally equivelant to the following loop
{
    // note that the array is cached so that you can't change its value or length during the loop body
    var thingCache = thing, lenCache = thingCache.length;
    for (var i = 0; i < lenCache; i++) { // the interator variable (i) will not be exposed to the loop body in a for in loop
        {
            var prop = thingCache[i];
            println(prop);
        }
    }
}
// if thing is an Object/Map then it is functionally equivelant to
{
    var thingCache = Object.keys(thing), lenCache = thingCache.length;
    for (var i = 0; i < lenCache; i++) { // the interator variable (i) will not be exposed to the loop body in a for in loop
        {
            var prop = thingCache[i];
            println(prop);
        }
    }
}
```

Here is example behavior
```ts
for (const num in [9, 8, 7]) {
    println(num)
}
// >> 9
// >> 8
// >> 7

for (const key in .{a=1, b=2, c=3}) {
    println(key)
}
// >> a
// >> b
// >> c
```

Like with if statements and while loops you can opt into indentation scoping instead of block scoping.

```ts
for (var i = 0; i < 4; i++):
    println(i)

for (var i = 0; i < 4; i++): println(i)

for (const i in [0, 1, 2, 3]):
    println(i)

for (const i in [0, 1, 2, 3]): println(i)
```

## Control flow in loops
### break
By default the `break` keyword exits the innermost loop that it is called in. If the loop that is exited is inside a parent loop then the parent loop will continue to iterate.
```ts
for (var i = 0; i < 5; i++) {
    if (i == 2): break
    println(i)
}
// >> 0
// >> 1
```

You can specify how many layers of loops to break out of. `break 0` will break out of the current loop and then immediately jump back into it. In other words is functionally equivelant to `continue` in other languages.
```ts
for (var i = 0; i < 5; i++) {
    if (i == 2) break 0
    println(i)
}
// >> 0
// >> 1
// >> 3
// >> 4
```

`break 1` is equivelant to `break`

`break 2` will jump out of the current loop and its parent loop
```ts
for (var x = 0; x < 3; x++) {
    for (var y = 0; y < 5; y++) {
        if (y == 2):
            break 2
        print("${x},${y}")
    }
}
// >> 0,0
// >> 0,1
```
vs
```ts
for (var x = 0; x < 3; x++) {
    for (var y = 0; y < 5; y++) {
        if (y == 2):
            break
        print("${x},${y}")
    }
}
// >> 0,0
// >> 0,1
// >> 1,0
// >> 1,1
// >> 2,0
// >> 2,1
```