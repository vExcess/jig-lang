# Strings
`String`s are special char[] Arrays. Unlike JavaScript, Strings are not primitives and are passed around by reference rather than value. Because Strings are Arrays, individual characters can be read and written to using the [] operator. Accessing an index that doesn't exist is a runtime error.

## Equality
Most of the time you want to check if two Strings contain the same value rather than checking if they have the same pointer. For this reason `==` checks if two Strings contain the same characters. If you want to check if two Strings are exactly the same object use `str1 === str2`. Calling `String()` on any value attempts to cast it to a String.
```ts
var str1 = "123"; // string
var str2: String = "123"; // string
var str3 = new String("456") // why would you do this?

str1 == str2 // true
str1 === str2 // false

str2 = str1;
str1 === str2 // true
```
Just like arrays, use the `.length` property to read the length of the String. Strings inherit all of Array's methods however it also has additional methods and some of Array's methods are overloaded in String.

## char
Single quotes ('') are used for creating a char not a String. Putting more than one character between two single quotes is a syntax error. Also chars do not have any methods as they are a primitive data type. For many functions and operations if you try using a char as a String then Jig will automatically convert the char into a String.
```ts
var c = 'c'; // this is a char not a string
```

## String Syntax
### " String
Double Quotes ("") are used for creating a templated String. They have special behavior at declaration time allowing them to interpolate data. Data is interpolated by escaping the String with `${expression}`. The expression gets evaluated and injected into the string.
```ts
// holds "AAA 3 BBB"
var s = "AAA ${1 + 2} BBB";
```

### """ String
Double-triple Quotes ("""""") are used for creating a templated multiline String. They behave the same as regular templated strings, but they are allowed to span across multiple lines. 
```ts
// holds "AAA\n3\nBBB"
var s = """AAA
${1 + 2}
BBB""";
```

### ` String
Backtick Strings are raw strings. They are not templated, don't handle escape sequences (except for escaped backticks), and allow multiple lines.
```ts
// holds "AAA\nBBB\\n\\n"
var s = `AAA
BBB\n\n`;
```
If your string is in an indented block you probably don't want the indentation in the string. Because of this by default raw strings strip off the indentation from each line of the string. This can be avoided by prepending the raw string with `String.raw`
```ts
{
    // holds "AAA\nBBB"
    var s = `AAA
    BBB`;

    // holds "\nAAA\n    BBB\nCCC\n"
    var s = `
    AAA
        BBB
    CCC
    `;

    // holds "AAA\n    BBB"
    var s = String.raw`AAA
    BBB`;
}
```

### Escaping in Strings
You can escape characters in a String by placing a backslash `\` behind it. Escaping can be used to have quotes or backticks inside of a String without closing it.
```
// holds `he said "blah blah" on wednesday`
var s = "he said \"blah blah\" on wednesday"

// holds "he said \\\${thisIsNotEvaluated} wednesday"
var s = `he said \${thisIsNotEvaluated} wednesday`

// holds "he said ` wednesday"
var s = `he said \` wednesday`
```
Most characters when escaped are themselves however there are special escape characters  
"\n" -> line feed  
"\t" -> tab  
"\r" -> carriage return  
"\f" -> form feed  
"\b" -> backspace character  
If you want to have backslashes in your String you need to escape the backslash
```
// prints out a single backslash becuase the first one escapes the second one
println("\\");
```
Other special escape sequences are for representing non-ASCII characters in a String. You can use hexadecimal or unicode escape sequences. Hexadecimal escape sequences start with "\x" which is followed with exactly 2 hexadecimal characters. If the hexidecimal for your character is only one character long it must be padded with a leading 0. Unicode escape sequences start with "\u" which is followed with exactly 4 hexadecimal characters. If the hexidecimal for your character is less than 4 characters long it must be padded with leading zeros. The hexidecimal characters in the escape sequence are case insensitive ("A" and "a" are the same).
```
"\xA9" // ©
"\u00A9 // ©
```

## String Methods
String.prototype.charAt - `"A".charAt(0)` -> `'A'` returns returns the character at a given index. Is functionally equivelant to `"A"[0]`

String.prototype.charCodeAt - `"A".charCodeAt(0)` -> `65` returns the ASCII value of the of the character at a certain index

String.prototype.startsWith - `"Abc".startsWith("Ab")` -> `true` returns whether the beginning characters of the String match the given String

String.prototype.endsWith - `"Abc".endsWith("bc")` -> `true` returns whether the last characters of the String match the given String

String.prototype.contains - `"Abc".contains("bc")` -> `true` returns whether the String contains the given String

String.prototype.indexOf - `"Abc".indexOf("bc")` -> `1` returns the index of the given String inside of the original String. Returns -1 if the String doesn't contain the given String

String.prototype.padStart - `"0".padStart(3, '1')` -> `"110"` takes two arguments. The first is a number which is the new length of the String. The second is the character to pad with. If no character is specified then a space character (' ') is used. It then pads the beginning of the String with the character until it reaches the specified length.

String.prototype.padEnd - `"0".padEnd(3, '1')` -> `"011"` takes two arguments. The first is a number which is the new length of the String. The second is the character to pad with. If no character is specified then a space character (' ') is used. It then pads the end of the String with the character until it reaches the specified length.

String.prototype.repeat - `"ab_".repeat(3)` -> `"ab_ab_ab_"` copies the String onto itself a given number of times

String.replace - `"caat".replace("a", 'b')` -> `"cbat"` replaces the first instance of a String with a new String. If no replacement String is specified it is replaced with an empty String "". `"caat".replace("a")` -> `"cat:`

String.prototype.replaceAll - `"caat".replaceAll("a", 'b')` -> `"cbbt"` functions the same as String.replace except it replaces every instance of the given String with the replacement String. Note: The method only does one scan through the loop so `"abab".replaceAll("a", "ab")` results in `abbabb` rather than an infinite loop.

String.prototype.split - `"aa_bb_cc".split("_")` -> `["aa", "bb", "cc"]` splits the String into an array of substrings and returns the array. It splits the String at every instance of a specified character/String and if no parameter is given then an empty String is used resulting in the String being split at each character.

String.prototype.toUpperCase - `"abc".toUpperCase()` -> `"ABC"` converts each character in the String to its upper case equivelant

String.prototype.toLowerCase - `"ABC".toLowerCase()` -> `"abc"` converts each character in the String to its lower case equivelant

String.prototype.trim - `"   abc   ".trim()` -> `"abc"` removes all whitespace characters from both ends of the String

String.prototype.trimStart - `"   abc   ".trimStart()` -> `"abc   "` removes all whitespace characters from the start of the String

String.prototype.trimEnd - `"   abc   ".trimEnd()` -> `"   abc"` removes all whitespace characters from the end of the String

## String Static Methods
String.fromCharCode - `String.fromCharCode(65)` -> `"A"` converts an ASCII value into a String if the argument is a number. If the argument given is an array then it goes through the array converting each item to a String and then joins the result. `String.fromCharCode([65, 66, 67])` -> `"ABC"`
