## Arrays
Arrays can only store one type of data (eg: you cannot store ints and floats in the same array). No characters (including spaces) are allowed between the array literal's type anotation and its initializer. Arrays are created with the following syntaxes:
```ts
// auto detect array type (in this case []i32)
var arr = [1, 2, 3];

// specify array type.
var arr: []f32 = [1, 2, 3];

// creates an array of length 3, is filled with 0's by default: [0, 0, 0]
var arr = new [3]i32;

// !!!!!ERROR!!!!! i32[] can NOT store f32[]
var arr: i32[] = new [3]f32;

// Array can store any type of array
var arr: Array = new [3]i32;
var arr: Array = new [3]f32;

// Object can store any type of object including arrays, functions, and Strings
var arr: Object = new [3]i32;
var arr: Object = "Hello";

// You can use an Object array to store different types of objects
var arr: []Object = [new House(), new Person()];

// You can create 2D arrays like so
var arr: [][]i32 = [
	[1,  2,  3,  4],
	[5,  6,  7,  8],
	[9, 10, 11, 12], // one trailing comma is allowed
];
var arr: [][]i32 = new [3, 4]i32; // results in the same layout as directly above but is filled with 0's by default
// And 3D arrays
var arr: [][][]i32 = [
	[
		[1],
		[2],
	],
	[
		[3],
		[4],
	],
	[
		[5],
		[6],
	],
];
var arr = new [3, 2, 1]i32;
```

## Array Access
To access an item in an array use `arr[index]` (eg: `arr[0]`). This same syntax is used when writing to an index in an array `arr[index] = 0;`. Indices start at zero. Arrays can only store 2^31 items. Accessing an index less than 0 or greater than the length of the array will throw an array out of bounds error. To access the length of the array use the readonly length property `arr.length` which returns the number of items in the array. If you need to grow or shrink the array use `arr.resize(newLength);` method which will resize the array to the specified size. If the array is shrunk all the clipped off data is lost. To take a slice of an array you can use the slice method `arr.slice(0, 10)` or use the bracket notation` arr[0:10]`. If the first number is unspecified (eg: `arr[:10]`) then it is 0, if the second number is unspecified (eg: `arr.slice(0)` or `arr[0:]`) then it is the length of the array. If no parameters are specified (eg: `arr[:]` or `arr.slice()`) then it shallow clones the entire array. If you do not have a colon inside of the bracket notation like so `arr[]` it's a compiler error. No characters (including spaces) are allowed between the array's identifier and the accessor open bracket.

### arr.last
arr.last is syntax suguar for arr[arr.length - 1].
```ts
var arr = [1, 2, 3]
arr.last // 3
arr.last = 999
print(arr) // 1, 2, 999
```

## Array Methods
Array.prototype.add - `arr.add(123)` is functionally equivelant to `arr.resize(arr.length+1); arr[arr.length-1] = 123;`. You can also push multiple elements at the same time `arr.push(123, 456)`

Array.prototype.removeAt - `arr.removeAt(0)` removes an item from an array at a specified index. The following elements are then shifted left to take its place and the array is shrunk. Multiple items can be popped from an array at the same time `arr.removeAt(0, 1, 2)`.

Array.prototype.contains - `arr.contains(123)` returns a true or false depending on whether the array contains the given item

Array.prototype.indexOf - `arr.indexOf(123)` returns the index of an item in an array. Returns -1 if the item is not included.

Array.prototype.toString - `arr.toString(str)` converts each item to a String and joins them together seperated by the value of `str` and returns the resulting String. If no arguments are given the default str is a comma.

Array.prototype.filter - `arr.filter((item, index) => { item % 2 == 0 });` takes a function that is given two parameters, the function is then called on each item in the array and is provided the item and its index. The method returns a sub array containing only the items that returned true when run through the function.

Array.prototype.map - `arr.map((item, index) => { item + 1 })` Creates a shallow clone of the array and sets each item to the result of running the item and its index through the given function

Array.prototype.forEach - `arr.forEach((item, index) => { println(item) })` Runs the given function on each item in the array. The parameters given to the function are the item and the index in the array.

Array.prototype.find - `arr.find((item, index) => { item % 2 == 1 });` takes a function that is given two parameters, the function is then called on each item in the array and is provided the item and its index. This happens until the given function returns true. The find method then returns the item that resulted in true.

Array.prototype.reverse - `arr.reverse()` reverses all items in the array so that the first item is the last and the last is the first

Array.prototype.sort - `arr.sort((a, b) => { return a - b })` if the items are numbers and no argument is given then they will be sorted into order from smallest to largest. If items are Strings and no argument is given they will be sorted according their ASCII values from smallest to largest. If items are neither numbers nor Strings a function must be given as an argument that takes two items and returns a number, otherwise is a type error.

Array.prototype.append - Appends arrays to the "this" array. An error is thrown if the items in the other arrays cannot be cast to the type of this array. `arr1.concat(arr2, arr3)`

Array.concat - Concatenates multiple arrays together and returns a new array. The new array will have the type of the first array. An error is thrown if the items in the other arrays cannot be cast to the type of the first array. `Array.concat(arr1, arr2, arr3)`
