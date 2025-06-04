# Reserved Words

## Keywords
var, let, const, if, else, do, while, for, struct, class, private, static, super, extends, inherit, enum, try, catch, throw, return, switch, yield, case, default, break, continue, new, this, true, false, Infinity, import, export, from, as, async, await, typeof, undefined

## Built in data types
bool, u8, i16, u16, char, i32, u32, i64, u64, f32, f64, void, null, BigInt  
Object, Array, Function, Struct, Class, String

## Primitive Data Types
Primitive data types are passed by value rather than by reference. I used to prefer C-style type identifiers, but I've come to accept that Zig-style type identifiers are better because they are a consistent length and provide information about the type in memory without having to do conversions in your head.  
**u8** - An unsigned 8-bit integer  
**i16** - A signed 16-bit integer  
**u16** - An unsigned 16-bit integer  
**char** - An unsigned 16-bit integer that stores represents a Unicode character    
**i32** - A signed 32-bit integer  
**u32** - An unsigned 32-bit integer  
**i64** - A signed 64-bit integer  
**u64** - An unsigned 64-bit integer  
**f32** - A signed 32-bit floating point number  
**f64** - A signed 64-bit floating point number  
**void** - A special primitive data type that is a placeholder for nothing.  
**null** - Similar to void, null is a special primitive data type that points to nothing. Object, Array, and String variables that are undefined point to null.  
**BigInt** - Capable of holding signed integers of arbitrarily large size  

## Non-primitive Data Types
Non-primitive data types are passed by reference rather than value  
**Object** - The root class of all other classes and objects  
**Array** - A special type of object where each key is an integer that can be read/write using the [] operator  
**Function** - Functions are objects so that they can be treated like first class functions and be passed around by reference  
**Struct** - is just an alias to Function  
**Class** - A blueprint for creating Objects  
**String** - Strings are a special type of char array that has extra methods

## BigInt
BigInts are integers of arbitrarily big size. BigInts are a primitive data type. They work with all arithmetic and bitwise operators in the same way a regular integer would. Arithmetic operators on a BigInt can only be done with another BigInt. Trying to add a BigInt and a regular int will result in a type error. 
```
// BigInts can be created using the BigInt function
BigInt a = BigInt("123"); // The BigInt function expects Strings
BigInt b = BigInt(123); // 123 is implicitly cast to a String and then a BigInt
var c = 123n; // for the sake of concise code adding an "n" after a number converts it into a BigInt
var d = BigInt("123.99"); // becomes 123 because all floating point data is truncated
```

## Integer Overflows/Underflows
Integer overflows/underflows throw an error in safe mode. Otherwise they behave the same as overflows in C.
