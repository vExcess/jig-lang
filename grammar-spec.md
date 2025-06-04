# Language Specification

## Grammar
```js
Program =
    Declaration*

Declaration =
    ClassDeclaration
    | StructDeclaration
    | EnumDeclaration
    | FunctionDeclaration
    | VariableDeclaration
    | "export" ClassDeclaration
    | "export" StructDeclaration
    | "export" EnumDeclaration
    | "export" FunctionDeclaration
    | "export" VariableDeclaration
    | Statement
    | Label Statement

ImportIdentifiers =
    Identifier ("as" Identifier)? ("," Identifier ("as" Identifier)?)*
    | "{" Identifier ("as" Identifier)? ("," Identifier ("as" Identifier)?)* "}"
ImportStatement =
    "import" (ImportIdentifiers | "*") "from" String ("hide" ImportIdentifiers)?

Label =
    Identifier ":"

ClassVariableDeclaration =
    "static"? MutabilityModifier? Identifier TypeAnnotation? ("=" Expression)
    | "static"? MutabilityModifier? Identifier TypeAnnotation ("=" Expression)?
    | "inherit" Identifier+ "from" Identifier ("as" Identifier+)?
    | "static" EnumDeclaration

MethodDeclaration =
    Identifier "(" Parameters? ")" TypeIdentifier? Block

ClassDeclaration =
    "class" Identifier ("extends" Identifier ("," Identifier)*)? "{" (ClassVariableDeclaration | MethodDeclaration)* "}"

StructDeclaration =
    "struct" Identifier "{" (MutabilityModifier? Identifier TypeAnnotation ("=" Expression)? ";")* "}"

EnumDeclaration =
    "enum" Identifier? "{" (Identifier ("=" Expression)?)* "}"

TypeAnnotation =
    ":" TypeIdentifier

Parameter =
    Identifier TypeAnnotation?
Parameters =
    Parameter ("," Parameter)*

Arguments =
    Expression ("," Expression)*

FunctionExpression =
    "async"? "(" Parameters? ")" TypeIdentifier? "=>" Block

FunctionDeclaration =
    "async"? "fn" Identifier "(" Parameters? ")" TypeIdentifier? Block

Block =
    "{" Declaration* "}"

MutabilityModifier =
    "var" 
    | "let" 
    | "const"

VariableDeclaration =
    MutabilityModifier ((Identifier | ("(" Identifier ("," Identifier)* ")")) TypeAnnotation? ("=" Expression)?)*

Statement =
    Expression
    | ForStatement
    | WhileStatement
    | DoStatement
    | IfStatement
    | ReturnStatement
    | Block

ForStatement =
    "for" "(" (VarDeclaration | Expression)? ";" Expression? ";" Expression? ")" Statement
    | "for" "(" MutabilityModifier Identifier ("in" | "of") Expression ")" Statement

WhileStatement =
    "while" "(" Expression ")" Statement

DoStatement =
    "do" Statement "while" "(" Expression ")"

IfStatement =
    "if" "(" Expression ")" Statement ("else" statement)?

Range =
    Expression ".." Expression

SwitchCase =
    ((Expression | Range | "else") ("," (Expression | Range | "else"))*) "=>" (Expression | Block)

SwitchStatement =
    "switch" "(" Expression ")" "{" (SwitchCase ("," SwitchCase)*) "}"

ReturnStatement =
    "return" Expression?

Cast = 
    "<" TypeIdentifier ">" Expression

Expression = 
    assignment
assignment =
    (call ".")? Identifier "=" assignment
    | (call ".")? Identifier "+=" assignment
    | (call ".")? Identifier "-=" assignment 
    | (call ".")? Identifier "*=" assignment 
    | (call ".")? Identifier "/=" assignment 
    | (call ".")? Identifier "**=" assignment 
    | (call ".")? Identifier "<<=" assignment 
    | (call ".")? Identifier ">>=" assignment 
    | "[" Expression "]" "=" assignment
    | prec6
prec6 = 
    prec5 ("||" prec5)*
prec5 =
    prec4_3 ("&&" prec4_3)*
prec4_3 =
    prec4_2 ( ("|") prec4_2 )*
prec4_2 =
    prec4_1 ( ("^") prec4_1 )*
prec4_1 =
    prec4 ( ("&") prec4 )*
prec4 =
    prec3 ( ("!=" | "==") prec3 )*
prec3 =
    prec2_5 ( (">" | ">=" | "<" | "<=" | "in" | "is") prec2_5 )*
prec2_5 =
    prec2 ( ("<<" | ">>") prec2 )*
prec2
    = prec1 ( ("-" | "+") prec1 )*
prec1 =
    prec0 ( ("/" | "*" | "%") prec0 )*
prec0 =
    unary ("**" unary)*
unary = 
    ("!" | "-" | Cast | "++" | "--" | "~" | "+" | "await") unary | call
call =
    primary ("(" Arguments? ")" | "." Identifier | ("[" Expression "]"))*
primary = 
    "true" 
    | "false" 
    | "null" 
    | "this"
    | Number 
    | BigInt
    | String 
    | ArrayLiteral
    | MapLiteral
    | Identifier 
    | "(" Expression ")"
    | "super" "." Identifier

ArrayLiteral =
    "[" (Expression ("," Expression)* ","?)? "]"

MapEntry =
    Identifier ":" Expression
    | "..." Identifier
MapLiteral =
    "{" (MapEntry ("," MapEntry)*)? "}"

BigInt =
    Number "n"?

Number = 
    Digit+ ("." Digit+)?

String =
    "\"" [^"\""]* "\""

TypeIdentifier =
    Identifier
    | ("[" Expression? "]")* Identifier

Identifier =
    Alpha (Alpha | Digit)*

Alpha =
    [a-zA-Z_]

Digit =
    [0-9]
```
