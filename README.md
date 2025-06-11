# Jig
A type-safe general purpose programming language designed to combine Javascript with Zig.

Jig gets rid of the stupid features of JavaScript that nobody uses such as Object 
plus Array equaling Number, and Array plus Number equaling String (https://www.destroyallsoftware.com/talks/wat). JavaScript also has ambiguous syntax 
that Jig does away with. 

Jig gets rid of much of the strictness of Zig and allows you to focus on writing
code rather than chasing down missing semicolons, unused variables, and explicitly
casting numbers.

Jig's core philosophy is to cater to multiple programming styles by offering 
the best of both worlds. It offers static typing and dynamic typing, simplicity 
and speed, garbage collection and no garbage collection, JIT compilation and AOT 
compilation, procedural programming and OOP, semicolons and no semicolons, and more.

## Learn Jig
Read the book here:  
[https://github.com/vExcess/jig-lang/tree/main/book](https://github.com/vExcess/jig-lang/tree/main/book)

## Feedback Appreciated
If you find any discrepancies or ambiguous cases in my specification please let
me know so that I can fix them.  Also compilers are sophisticated pieces of 
software with plenty of room for bugs to hide so please report any bugs you find.

## Notes:
  - The language implementation is work in progress so expect things to act broken.
  - I've tried to write a complete specification, but I'm sure there are details and edge cases I haven't thought about which will result in weird bugs.
  - Jig is theoretically capable of being faster than JavaScript, but time will tell if Jig can beat the insane optimizations Google has put into V8.

## Jig's Bootstrapper in Dart
Jig is a self hosted language; that is the Jig compiler is written in Jig. However, to run the Jig compiler we need an implementation in 
an external language. I have chosen to write the bootstrapper implementation of Jig in Dart. The bootstrapper is designed to be as simple
as possible. Any time there is a simplicity vs performance tradeoff, the bootstrapper chooses simplicity. The bootstrapper is a best effort
implementation of Jig. Ideally it implements Jig perfectly, but as long as it implements Jig well enough to compile the Jig compiler it's
good enough.  
How it works: The Dart interpreter interprets the bootstrapper code which interprets the Jig compiler which compiles the Jig compiler which is
then able to be used to interpret or compile other Jig source code.

## Execution
Jig source code is stored in a ".jig" file. The plan is for Jig to be interpreted, compiled to native code, or compiled to web assembly.

### Compilation to WebAssembly or Machine Code
Using the `#aot-compile` compiler flag increases strictness allowing the program to be compiled ahead of time instead of just in time. 

## Example Code
Here's so you can get a quick feel for the language syntax without reading the Jig Book
```rs
class Animal {
    name: String,
    age: u32,
    new(this.name, this.age)
}

class LandAnimal extends Animal {
    new(...args) { Animal(...args) }
    move() { println("Walk") }
}

class WaterAnimal extends Animal {
    new(...args) { Animal(...args) }
    move() { println("Swim") }
}

class Platypus extends WaterAnimal, LandAnimal {
    new(...args) {
        WaterAnimal(...args)
        LandAnimal(...args)
    }
    inherit move from LandAnimal as walk
    inherit move from WaterAnimal as swim
}

const perry = new Platypus("Perry", 148)
println(perry.name) // >> Perry
println(perry.age) // >> 128
perry.walk() // >> Walk
perry.swim() // >> Swim

const characters = ["Bob", "Alice", "Eve"]
characters
    .map((name) => { name.toLowerCase() })
    .sort()

for name in characters:
    println(name)
// OR
for (name in characters) {
    println(name)
}
// >> alice
// >> bob
// >> eve

for (var i = 0; i < 5; i++) {
    if i == 2:
        break
    println(i)
}
// >> 0
// >> 1

fn random(start, stop) @typeof(start) {
    return <@typeof(start)> (Math.random() * (stop - start) + start);
}

const num = random(-1000, 1000.0);
const about: ?String = switch (num) {
    -Infinity..-1 => {
        "myValue is negative"
    },
    0..5, 6, 7, 8, 9 => 
        "myValue is a single digit",
    else =>
        null
};

if (num) { // same as num != null
    // num is no longer a String | null union
    println(num);
}
```