## arithmetic operators
`+` add two numbers or concatenate Strings  
`-` substract two numbers  
`*` multiply two numbers  
`/` divide two numbers  
`**` raise one number to the power of another  
`%` modulus (the remainder from division)  

## assignment operators
`++` increment a number variable by 1  
`--` decrement a number variable by 1  
`=` assignment operator (assigns a value to a variable)  
`+=` increments a number variable by a given amount  
`-=` decrements a number variable by a given amount  
`*=` multiplies a number variable by a given amount  
`/=` divides a number variable by a given amount  
`%=` sets number variable to itself modulus given amount  
`**=` sets number variable to itself to the power of given amount  

## comparison operators
`==` equality operator (checks if two values are equal)  
`===` strict equality operator (checks if two values have the exact same memory address)  
`!=` inequality operator (checks if two values are not equal)  
`>` greater than operator (checks if one number is greater than another)  
`<` less than operator (checks if one number is less than another)  
`>=` greater than or equal to operator (checks if one number is greater than or equal to another)  
`<=` less than or equal to operator (checks if one number is less than or equal to another)  
`? : ` ternary operator (basically a shorthand if statement that returns a value)  

## logical operators
`&&` checks if one boolean and another boolean are both true  
`||` check if one boolean, another boolean, or both is true  
`!` check if one boolean is not true  

## bitwise operators
bitwise operators convert their operands into 32 bit integers and then the operation is performed on each pair of bits  
`&` bitwise AND  
`|` bitwise OR  
`~` bitwise NOT  
`^` bitwise XOR (exclusive or aka ((A || B) && !(A && B)))  
`<<` left bit shift (shifts the bits of the number left. Bits do not wrap aka are discarded and empty bits are 0)  
`>>` right bit shift (shifts the bits of the number right. Bits do not wrap aka are discarded and empty bits are 0)  
`>>>` unsigned right bit shift (The sign bit is set to 0. shifts the bits of the number right. Bits do not wrap aka are discarded and empty bits are 0)  

## bracket operators
`[val]` The bracket operator is used to access arrays `arr[number]` (see Arrays section). It is also can be used to access properties of an object `obj[String]`. It is also used to create arrays `type[] = new int[](number);`  
`.val` The dot operator is used to access properties of an object `obj.prop`  
`<type>` casting operator explicitly casts a value to a new type  

## typeof operator
typeof is a built in keyword that returns the type of a value
```
typeof 1 // returns i32
typeof 1.0 // returns f64
typeof "" // returns String
typeof [] // returns Array
typeof .{} // returns Object
typeof () => {} // returns Function
```