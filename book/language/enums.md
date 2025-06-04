# Enums
Enums are an easy way to group multiple variables together in an incrementative or non-incrementative manner. All variables created with an enum are constants. Each identifier is seperated by a comma. Trailing commas are allowed. Currently items in enums can't be typed. This may change.
```ts
enum {
    a, b, c
}
a // 0
b // 1
c // 2
```
You can also give the enum a name making all variables properties of that name
```ts
enum JIT {
    a, b, c
}
JIT.a // 0
JIT.b // 1
c // throws reference error
```
By default the enum variables value is the index of the variable name in the enum starting from 0, but this can be overridden
```ts
enum {
    a, b = "bar", c
}
a // 0
b // "bar"
c // 2
```
Enums can be nested in prototypes
```ts
prototype Foo {
    static enum { a, b, c }
    enum { d, e, f }
    new() {
        this.d // 0
    }
}
Foo.a // 0
Foo.b // 1
new Foo().d // 0
```
Or for extra fun you could use a struct, function, class, etc as the value of an enum item
```ts
enum IpAddr {
    v4 = (ip) => { ip },
    v6 = String,
    iDunno = struct {
        lol: String
    }
}

var home = new IpAddr.v4("127.0.0.1");
var loopback = IpAddr.v6("::1");
var haha = IpAddr.iDunno("haha").lol;
```

