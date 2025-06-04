# Casting
Having to memorize various different casting rules can be a big pain and manually needing to cast each parameter going into an operation is both tedious and makes for lengthy code. Jig will attempt to implicitly cast any piece of data to the needed type for you, but will throw an error if casting fails.

The syntax for casting is:
```
<type> value

EXAMPLE:
<i32> 123.987 // becomes 123
```
Jig's implicit casting rules are simple. All numbers can be cast to any other type of number (except BigInt at the moment). When operating on two numbers Jig will promote the operand of a lesser type to the other operand's type in order to prevent data loss. For example if you multiply an int by a float it will automatically cast the int to a float before perfoming the operation.

### Number Casting Rules
1)  If one operand is floating point and the other is not then the none floating point operand will be promoted to floating point
2)  If one operand's type has less bits than the other, it is cast to the type that has more bits
3)  If one operand is signed and the other not, the non-signed operand is promoted to be signed.

### String Casting Rules
- If concatenating a char and a String, the char will automatically be cast to a String.
- If casting a String to a char, the result will be the first character in the String.
- When any number is being cast to a String the result will be the decimal text of the number (eg: `<String>(65)` -> `"65"`). The exception to this is the char number type. When chars are cast to a String they form a single character long String where the character is based on the ASCII value of the char. Essentially `<String>(myChar)` is equivelant to `String.fromCharCode(myChar)` (eg: `<String>(<char> 65)` -> `"A"`)
- Although numbers are implicitly cast to Strings, Strings are not implicitly cast to numbers and will throw a type error if you try

### Literal Casting Rules
Any number literals that have decimal points are f64, otherwise the literal is i32
```
var num = 1; // num is an i32
var num = 1.0; // num is a f64
var num = 1.; // also a f64; trailing decimals are allowed
```
If you try implicitly casting anything not following the rules above then a type error will be throw.