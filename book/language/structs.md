# Structs
Structs are used for grouping values together. They are like classes, but without methods or static attributes. When creating an instance of a struct do not use the `new` keyword. Structs can also be instantiated using the Rust style syntax.
```ts
struct myStruct {
    x;
    y;
    z;
}

// C-like syntax
var vec = myStruct(1, 2, 3);

// Zig-like syntax
var example = myStruct{
    x = 1,
    y = 10,
    z = 100
};

// Anonymous struct
var example: myStruct = .{
    x = 1,
    y = 10,
    z = 100
};

// typing your struct properties
struct typedStruct {
    x: i32 = 0;
    y: i32;
    z: i32;
}
var vec = typedStruct(1, 2, 3);
vec.x // 1
```
Structs can be nested in classes
```ts
class Foo {
    struct Bar {
        a;
        b;
        c;
    }
}
```