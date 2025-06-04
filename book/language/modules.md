# Module System
A jig file can export a value and another jig files can import values from other files. 

## export
Any type of value can be exported, however only global values can be exported. To export a value simply use the `export` keyword followed by an expression. The exported output will be an object containing key-value pairs for all the exported items.

Examples:
```ts
let num = 123.456;
export num;
```

```ts
fn someFunc() {
    println("Hello")
}
export someFunc;
```

```ts
export fn() {
    println("Hello")
};
```

```ts
enum NUMBERS {
    a, b, c
}
export {
    nums: NUMBERS,
    compile: fn() {},
    transpile: fn() {},
    genAST: fn() {}
};
```

```ts
export enum NUMBERS {
    a, b, c
}
export fn compile() {}
export fn transpile() {}
export fn genAST() {}
```

## import
Any type of value can be imported, however you can only import values from files that have exported them. You can also only use an import statement in the global scope. You can import specific exports like so
```ts
import PROP1, PROP2, PROP3 from "PATH_TO_FILE"
```
The "PATH_TO_FILE" can contain both absolute and relative URLs. If using a relative URL then the URL is relative to the file using `import` rather than relative to the compiler. Relative URLS start with "./". The convention is to use forward slashes `"./lib`, but because of Windows backward slashes are also allowed `".\lib"`. The path must be a double quote string. You do not need to specify `.jig` at the end of the path. Circular imports are not allowed. In a web environment you can import from http/https URLs.

If your object has a lot of properties you may want to use the wild card syntax
```ts
import * from "PATH_TO_FILE"
```
which will import every property from the object into the current scope. To avoid polluting the global scope use
```ts
import * from "PATH_TO_FILE" as MyLib
```

You can use the `as` keyword to change the name of an identifer you have imported
```
import a as x, b as y, c as z from "./library"
```

Lastly you can put the first part of the import statement in curly braces just because it can make the code easier to read
library.jig
```ts
import { a as x, b as y, c as z } from "./library"
import { * } from "./library"
import { stuff } from "./library"
```
