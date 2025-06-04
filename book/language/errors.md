# Throwing and catching errors
Unlike most languages, Jig takes after Zig in that errors are part of a function's return value and are not something that can be arbitrarily thrown.

Essentially errors are an enum that is defined. When an error is thrown it can have a string description attached.

```ts
error MyErrors {
    OUT_OF_BOUNDS
}

function stringOrErr(a) !String {
    if (a > 0):
        return a
    
    // return error without description
    return MyErrors.OUT_OF_BOUNDS
    // OR
    // return error with description
    return MyErrors.OUT_OF_BOUNDS("a can't be negative")
}

// thing has a type of !String
var thing: !String = stringOrErr(1);
(thing + 1) // error: can't add potential error with 1
```

To un-error-union the result of a function that returns an error use `try`. The try means that the current function will return the error if it exists, otherwise will continue executing with the value returned by stringOrErr.
```ts
var thing: String = try stringOrErr(1);
(thing + 1) // this is fine now yay!
```

To handle the error yourself instead of passing it to the calling function use `catch`
```ts
// default to -1 if an error occured
var thing: String = stringOrErr(1) catch -1;
```
```ts
// log and exit instead of recovering
var thing: String = stringOrErr(1) catch (err) {
    // log the error
    println(err.category)
    println(err.name)
    if (err.description != null):
        println(err.description)
    
    // exit program execution
    @panic("Unrecoverable error happend")
};
```

Because it is tedious to manually handle every error that could happen you can use a try/catch block to handle errors that occured in any of the calls within it.

```ts
try {
    // if either of the follow calls errors we immediately return to the caller function
    var thing = stringOrErr(1)
    var thing2 = stringOrErr(0)
}
```

```ts
// in this case if either error, we log the error and just return null to the caller function
try {
    var thing = stringOrErr(1)
    var thing2 = stringOrErr(0)
} catch (err) {
    println(err)
    return null
}
```