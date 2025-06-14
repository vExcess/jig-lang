# Welcome

Jig is a type-safe general purpose programming language designed to combine Javascript with Zig.

Jig gets rid of the stupid features of JavaScript that nobody uses such as Object 
plus Array equaling Number, and Array plus Number equaling String (https://www.destroyallsoftware.com/talks/wat). JavaScript also has ambiguous syntax 
that Jig does away with. 

Jig gets rid of much of the strictness of Zig and allows you to focus on writing
code rather than chasing down missing semicolons, unused variables, and explicitly
casting numbers.

Jig's core philosophy is to cater to multiple programming styles by offering 
the best of both worlds. It offers static typing and dynamic typing, simplicity 
and speed, garbage collection and no garbage collection, JIT compilation and AOT 
compilation, semicolons and no semicolons, and more.

## Garbage Collection
Jig is garbage collected by default, but when necessary the `nogc` keyword can be used to give the programmer manual control over memory using the `new` and `free` keywords for maximum performance.

## Semicolons
Some think semicolons ought to be mandatory while others frown upon them. JavaScript says both are good. However the way JavaScript did it is absolutely awful. While JS makes semicolons technically optional; the use or lack thereof can drastically change the meaning of the code which very often leads to frustrating bugs. Jig on the other hand makes semicolons purely asthetic so that semicolons have zero effect on code behavior.

## Naming Conventions
- ordinary variables are in camelCase
- class/struct names are in PascalCase
- compile time constants are in SCREAMING_SNAKE_CASE

# Hello World
Create a file called `main.jig` with the following contents:
```ts
println("Hello World!")
```
Use `jig main.jig` to run it. `Hello World!` will be written to standard output

