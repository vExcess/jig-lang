# Variables
Variables are created in the format
```
MUTABILITY_SPECIFIER IDENTIFIER (COLON TYPE_IDENTIFIER)* EQUAL_SIGN EXPRESSION
MUTABILITY_SPECIFIER <- var | let | const
IDENTIFIER <- see rules for naming identifiers
COLON <- :
TYPE_IDENTIFIER <- IDENTIFIER
EQUAL_SIGN <- =
```

EXAMPLES:
```ts
const idk: i32 = 1;
var idk = 3; // Jig has implicit type inference
```
I used to prefer C-style variable declarations, but when programming you care about the name of the variable more than the variable's type so the name should come first as most people read left to right.  
Note that specifying the variable's type is completely optional. If the type is left unspecified the compiler/runtime will detect the variable type automatically.  

## Mutability Modifiers
- Use `const` when the value a variable holds will never be modified and the variable itself will never be mutated. 
- Use `let` if the the value will be modified, but the variable itself will never be mutated.
- Use `var` if both variable and value and value are mutable

## Naming Rules
- identifiers can contain letters, digits, underscores, and dollar signs.
- identifiers cannot begin with a number
- identifiers cannot only contain an underscore
- identifiers are case-sensitive
- Reserved words cannot be used as identifiers.

## Null Unioned Variables
A variable of a certain type can only hold that type which does NOT include null. This can be amended by appending `?` to the type at the variable's declaration
```ts
var str: String = ""; // can only hold strings
var str: String? = null; // can hold strings or null
```

## Type Coercion & Shadowing
Assigning a value to a variable whose's data types don't match causes Jig to attempt to implicitly cast the value and throws a type error if it fails. Although you can't change a variable's data type, you can declare a new variable with the same identifer to shadow the old variable. Shadowing a variable will throw a compiler warning to alert the programmer about potential bugs. Even though it throws a warning the code will still compile and run. Use the `#shadow` flag above the variable declaration to disable the warning.  

## Scoping
All variables are block scoped
```ts
var a = 1;
var b = 2;
a // 1
b // 2
{
    a // 1
    b // 2
    a = 3;
    var b = 4;
    a // 3
    b // 4
}
a // 3
b // 2
```

## Undefined Variables
All variables must have a value before they are used. If the programmer knows a variable will be initialized later before use they can set the variable to `undefined` at its declaration.
```ts
var b: u32 = undefined;
```
Using a variable that is set to undefined throws a reference error.
```
var foo: u32 = undefined;
println(foo) // throws error
```
```
var foo: u32 = undefined;
foo = 123;
println(foo) // this is ok
```

## Multi Assignment
Initialize multiple variables to the same type and value
```ts
var [a, b, c]: u32 = 0;
a // holds 0 as u32
b // holds 0 as u32
c // holds 0 as u32
```
Initialize multiple variables of different types to the same value
```ts
var [a: u32, b: i32, c: i64] = 0;
a // holds 0 as u32
b // holds 0 as i32
c // holds 0 as i64
```
Assign multiple variables the the same value
```
[a, b, c] = 0;
```

## Destructuring Assignment
Be careful not to confuse multi assignment with destructuring. Note the `=` for multi assignment and `<-` for destructuring.

Array destructuring:
```ts
var [a, b, c]: u32 <- [1, 2, 3];
a // holds 1 as u32
b // holds 2 as u32
c // holds 3 as u32
```

Array destructuring with spreading:
```ts
var [
    a: u32,
    c: []u32,
    b: u32
] <- [1, 2, 3, 4, 5, 6];
a // holds 1 as u32
b // holds [2, 3, 4, 5] as []u32
c // holds 6 as u32
```

Object destructuring:
```ts
var [a, b, c]: u32 <- .{c=3, a=1, b=2};
a // holds 1 as u32
b // holds 2 as u32
c // holds 3 as u32
```
