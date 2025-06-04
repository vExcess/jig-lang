# Object(s)
Jig also allows you to create anonymous objects. Objects are created like so
```ts
Object myObj = .{
    key1: i32 = 123,
    key2 = 789,
};
```

You can get/set properties of an object using the dot operator. Getting or setting a property of an Object that doesn't exist throws an error.
```ts
myObj.key1 // 123
myObj.key1 = 456
```

You can create Maps as well. They are just objects, but more dynamic. Their properties don't need to be known at compile time. In addition their properties can be accessed using the bracket operator rather than just the dot operator.

```ts
var myValue = "key3";
Map myMap = .{
    key1: i32 = 123,
    key2 = 789,
    [myValue] = 1011,
};

myMap.key1 // 123
myMap["key3"] // 1011
```

You can create a new Object or Map that inherits properties of an old Object using the spread operator like so:
```
var oldObj = .{
    a: 1,
    b: 2
}
var newObj = .{
    ...oldObj,
    c: 3
}
```
If you are putting variables into an object you can do it like so. However this feels very redundant
```
var a = 1, b = 2;
var obj = .{
    a: a,
    b: b,
    c: 3
}
```
As a result you can also use the shorthand syntax
```
var a = 1, b = 2;
var obj = .{
    a,
    b,
    c: 3
}
```
An Object declaration can't directly use the same key twice
```
// !!!!! COMPILER ERROR !!!!!
{
    a: 1,
    a: 1
}
```
However you can when using the `[variable]` declaration syntax or when using the spread syntax. Note in the following example that the order matters and the end of the delcaration gets preference over the beginning.
```
var oldObj = {
    a: 1
}
var newObj = {
    ...oldObj,
    a: 2
}
newObj.a // 2

var oldObj = {
    a: 1
}
var newObj = {
    a: 2,
    ...oldObj
}
newObj.a // 1
```
