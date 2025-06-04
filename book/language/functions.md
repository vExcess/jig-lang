# Functions
If two functions declarations exist with the same identifier in the same scope then a compiler error is thrown. Function declarations are hoisted while function expressions are not. If no return type is specified then the return type defaults to void unless it is an arrow function.
```ts
// regular function
fn myFuncIdentifier(param: type, param2: type) returnType {
    // body
}
```

## Arrow Functions
Arrow functions don't have identifiers. The return type in arrow functions must be after the arrow. If an arrow function's body contains a single expression then that expression will be returned from the function unless the function explicitly has a void return type.
```ts
// arrow function
() => {
    // body
}
```

## Calling
A function is called with its identifier followed immediately by parenthesis. No characters (including spaces) are allowed between the functions's identifier and the open parenthesis. The arguments for the function are entered between the parenthesis seperated by commas.
```ts
myFunction(1, 2, 3);
```

## returnAny macro
For scripting purposes `#returnAny` can be used to change the default return type from `void` to `any`

## Function Examples:
Functions are first class objects.
```ts
#returnAny {
    // untyped function declaration (can return any type)
    fn add(a, b) {
        return a + b
    }

    // untyped function expression being assigned to a variable (can return any type)
    var add = fn (a, b) {
        return a + b
    };

    // untyped arrow function expression being assigned to a variable (can return any type)
    Function add = (a, b) => a + b;
}

// typed functions (they can only return floats)
fn add(a: f32, b: f32) f32 {
    return a + b
}
var f = fn(a: f32, b: f32) f32 {
    return a + b
};
var f = (a: f32, b: f32) => f32 {
    a + b
};
```

## Optional Parameters
Function parameters can be made optional by wrapping them in `[]`. If you don't provide a default value, the type of the parameter must be nullable.
```ts
fn printAdd(isRequired: i32, [isOptional: i32 = 100]) {
    println(isRequired + isOptional)
}
printAdd(1) // 101
printAdd(1, 2) // 3
```

```ts
fn printAdd(isRequired: i32, [isOptional: i32?]) {
    if (isOptional != null) {
        println(isRequired + isOptional)
    } else {
        println(isRequired)
    }
}
printAdd(1) // 1
printAdd(1, 2) // 3
```

## Named Parameters
Function parameters can be named. This means you must specify the name of the parameter when calling the function. Named parameters are optional if they are nullable or have a default value, but required otherwise. To make parameters named wrap them in `{}`. If a function has both optional and named parameters, the named parameters must be last both in the function definition and the call expression.
```ts
fn foo(
    isRequired: i32,
    [isOptional: i32?],
    {named1: i32, named2: i32 = 0, named3: i32?}
) {
    // ...
}
foo(1, named1: 0) // minimum required arguments passed
foo(1, 2, named1: 0)
foo(1, 2, named1: 0, named3: 2, named2: 1)
```

## Main
The identifier `main` is a special function name that if declared in the top level scope will get called without you calling it. Although you can declare a main function, it is not necessary to do so.
```
fn main(String[] args) {
    // this function gets called automatically when the program starts without the programmer needing to call it.
    // Depending on where the code is being run the main method might be given an array of Strings. For example if you were writing a command line program.
    println(args);
}
```

## Function Overloading
Jig doesn't have function overloading, but it does have the `any` type so that a function can change its code route based on the type of the argument.
```ts
fn myFunc(a: any) {
    if (typeof a == i32):
        println("handle int")
    else if (typeof a == f64):
        println("handle double")
    else:
        println("handle all other types")
}

myFunc(1); // prints handle int
myFunc(1.0); // prints handle float
myFunc(""); // prints handle all other types
```

## Returning from a function
The `return` keyword is used to return a value from a function. When the return keyword is encountered the function returns the expression that is after it and exits the function. If there is no expression after it then it returns void;
```ts
fn thing() {
	println(1);
	return 2;
	println(3); // this code is unreachable and will throw a compiler warning
}
println("got " + thing());
/*
1
got 2
*/
```
Any code after a return statement that is unreachable will throw a compiler warning. Note that if a value is on the line after the return statement it still gets returned
```ts
fn() {
	return
	1
}
// is equivelant to
fn() {
	return 1;
}
```