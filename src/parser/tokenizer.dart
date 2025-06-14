import 'dart:math' as Math;

import '../data/Token.dart';

Map<String, TokenType> ReservedWordTokenType = {
    "fn": TokenType.FN,
    "var": TokenType.VAR,
    "let": TokenType.LET,
    "const": TokenType.CONST,
    "typedef": TokenType.TYPEDEF,
    "if": TokenType.IF,
    "in": TokenType.IN,
    "of": TokenType.OF,
    "else": TokenType.ELSE,
    "do": TokenType.DO,
    "while": TokenType.WHILE,
    "for": TokenType.FOR,
    "struct": TokenType.STRUCT,
    "class": TokenType.CLASS,
    "static": TokenType.STATIC,
    "super": TokenType.SUPER,
    "extends": TokenType.EXTENDS,
    "inherit": TokenType.INHERIT,
    "enum": TokenType.ENUM,
    "try": TokenType.TRY,
    "catch": TokenType.CATCH,
    "return": TokenType.RETURN,
    "switch": TokenType.SWITCH,
    "case": TokenType.CASE,
    "break": TokenType.BREAK,
    "continue": TokenType.CONTINUE,
    "new": TokenType.NEW,
    "true": TokenType.TRUE,
    "false": TokenType.FALSE,
    "Infinity": TokenType.INFINITY,
    "import": TokenType.IMPORT,
    "export": TokenType.EXPORT,
    "from": TokenType.FROM,
    "hide": TokenType.HIDE,
    "as": TokenType.AS,
    "async": TokenType.ASYNC,
    "await": TokenType.AWAIT,
};

List<String> TypeIdentifiers = [
    // primitives
    "u8", "i16", "u16", "char", 
    "i32", "u32", "i64", "u64", 
    "f32", "f64", 
    "bool",
    "vec2", "vec3", "vec4",
    "void", "null", "BigInt"

    // non primitives
    "Object", "Array", "Map", "Set", "Function", "Struct", "Class", "String"
];

final chCode_0 = '0'.codeUnitAt(0);
final chCode_9 = '9'.codeUnitAt(0);
final chCode_a = 'a'.codeUnitAt(0);
final chCode_A = 'A'.codeUnitAt(0);
final chCode_z = 'z'.codeUnitAt(0);
final chCode_Z = 'Z'.codeUnitAt(0);
final chCode__ = '_'.codeUnitAt(0);
bool isDigit(String? chStr) {
    if (chStr == null) {
        return false;
    }
    final ch = chStr.codeUnitAt(0);
    return ch >= chCode_0 && ch <= chCode_9;
}

bool isAlpha(String? chStr) {
    if (chStr == null) {
        return false;
    }
    final ch = chStr.codeUnitAt(0);
    return (ch >= chCode_a && ch <= chCode_z) ||
        (ch >= chCode_A && ch <= chCode_Z) ||
        ch == chCode__;
}

class Tokenizer {
    String source;
    int lexemeStart = 0;
    int current = 0;
    int line = 1;
    Token? previous;

    Tokenizer(this.source);

    Token token(TokenType tokType) {
        return Token(tokType, lexemeStart, source.substring(lexemeStart, current), line);
    }

    String advance([int amt=1]) {
        // advance by 1
        // return previous char
        this.current += amt;
        return this.source[this.current - amt];
    }

    bool isAtEnd() {
        return this.current >= this.source.length;
    }

    String? peek([int amt=0]) {
        // look ahead or peek current char
        final idx = this.current + amt;
        if (idx < this.source.length) {
            return this.source[idx];
        } else {
            return null;
        }
    }

    void skipWhitespace() {
        while (!this.isAtEnd()) {
            switch (this.peek()) {
                case ' ': case '\t': case '\r': {
                    this.advance();
                }
                case '\n': {
                    this.line += 1;
                    this.advance();
                }
                case '/': {
                    if (this.peek(1) == '/') {
                        while (!this.isAtEnd() && this.peek() != '\n') {
                            this.advance();
                        }
                    } else if (this.peek(1) == '*') {
                        while (!this.isAtEnd() && (this.peek() != '*' || this.peek(1) != '/')) {
                            if (this.peek() == '\n') {
                                this.line++;
                            }
                            this.advance();
                        }
                        this.advance(2);
                    } else {
                        return;
                    }
                }
                default:
                    return;
            }
        }
    }

    Token number() {
        while (isDigit(this.peek())) {
            this.advance();
        }

        // look for fractional part
        if (this.peek() == '.' && isDigit(this.peek(1))) {
            // consume the '.'
            this.advance();

            while (isDigit(this.peek())) {
                this.advance();
            }
        }

        return this.token(TokenType.NUMBER);
    }

    bool checkKeyword(int startOffset, String rest)  {
        // check if slice of lexeme matches a string
        final startIdx = Math.min(this.source.length - 1, this.lexemeStart + startOffset);
        final endIdx = Math.min(this.source.length - 1, startIdx + rest.length);
        var slc = this.source.substring(startIdx, endIdx);
        return slc == rest && this.source[endIdx] == ' ';
    }

    TokenType identifierType()  {
        switch (this.source[this.lexemeStart]) {
            case 'a': {
                if (this.checkKeyword(1, "wait")) {
                    return TokenType.AWAIT;
                }
                if (this.checkKeyword(1, "sync")) {
                    return TokenType.ASYNC;
                }
                if (this.checkKeyword(1, "s")) {
                    return TokenType.AS;
                }
            }
            case 'c': {
                if (this.checkKeyword(1, "lass")) {
                    return TokenType.CLASS;
                }
                if (this.checkKeyword(1, "onst")) {
                    return TokenType.CONST;
                }
            }
            case 'd': {
                if (this.checkKeyword(1, "o")) {
                    return TokenType.DO;
                }
            }
            case 'e': {
                if (this.checkKeyword(1, "lse")) {
                    return TokenType.ELSE;
                }
                if (this.checkKeyword(1, "xport")) {
                    return TokenType.EXPORT;
                }
                if (this.checkKeyword(1, "xtends")) {
                    return TokenType.EXTENDS;
                }
                if (this.checkKeyword(1, "num")) {
                    return TokenType.ENUM;
                }
            }
            case 'f': {
                if (this.current - this.lexemeStart > 1) {
                    switch (this.source[this.lexemeStart + 1]) {
                        case 'a': {
                            if (this.checkKeyword(2, "lse")) {
                                return TokenType.FALSE;
                            }
                        }
                        case 'o': {
                            if (this.checkKeyword(2, "r")) {
                                return TokenType.FOR;
                            }
                        }
                        case 'r': {
                            if (this.checkKeyword(2, "om")) {
                                return TokenType.FROM;
                            }
                        }
                        case 'n': {
                            return TokenType.FN;
                        }
                    }
                }
            }
            case 'h': {
                if (this.checkKeyword(1, "ide")) {
                    return TokenType.HIDE;
                }
            }
            case 'i': {
                if (this.checkKeyword(1, "f")) {
                    return TokenType.IF;
                }
                if (this.checkKeyword(1, "n")) {
                    return TokenType.IN;
                }
                if (this.checkKeyword(1, "s")) {
                    return TokenType.IS;
                }
                if (this.checkKeyword(1, "mport")) {
                    return TokenType.IMPORT;
                }
            }
            case 'l': {
                if (this.checkKeyword(1, "et")) {
                    return TokenType.LET;
                }
            }
            case 'n': {
                if (this.checkKeyword(1, "ull")) {
                    return TokenType.NULL;
                }
                if (this.checkKeyword(1, "ew")) {
                    if (previous != null && previous!.tokType == TokenType.DOT) {
                        return TokenType.IDENTIFIER;
                    }
                    return TokenType.NEW;
                }
            }
            case 'o': {
                if (this.checkKeyword(1, "f")) {
                    return TokenType.OF;
                }
            }
            case 'p': {
                if (this.checkKeyword(1, "rint")) {
                    return TokenType.PRINT;
                }
                if (this.checkKeyword(1, "rivate")) {
                    return TokenType.PRIVATE;
                }
            }
            case 'r': {
                if (this.checkKeyword(1, "eturn")) {
                    return TokenType.RETURN;
                }
            }
            case 's': {
                if (this.checkKeyword(1, "uper")) {
                    return TokenType.SUPER;
                }
                if (this.checkKeyword(1, "truct")) {
                    return TokenType.STRUCT;
                }
                if (this.checkKeyword(1, "witch")) {
                    return TokenType.SWITCH;
                }
                if (this.checkKeyword(1, "tatic")) {
                    return TokenType.STATIC;
                }
            }
            case 't': {
                if (this.current - this.lexemeStart > 1) {
                    switch (this.source[this.lexemeStart + 1]) {
                        case 'h': {
                            if (this.checkKeyword(2, "is")) {
                                return TokenType.IDENTIFIER;
                            }
                        }
                        case 'r': {
                            if (this.checkKeyword(2, "ue")) {
                                return TokenType.TRUE;
                            }
                        }
                        case 'y': {
                            if (this.checkKeyword(2, "pedef")) {
                                return TokenType.TYPEDEF;
                            }
                        }
                    }
                }
            }
            case 'v': {
                if (this.checkKeyword(1, "ar")) {
                    return TokenType.VAR;
                }
            }
            case 'w': {
                if (this.checkKeyword(1, "hile")) {
                    return TokenType.WHILE;
                }
            }
        }

        final lexeme = this.source.substring(this.lexemeStart, this.current);
        if (TypeIdentifiers.contains(lexeme))
            return TokenType.TYPE_IDENTIFIER;

        if (lexeme == "Infinity")
            return TokenType.NUMBER;

        return TokenType.IDENTIFIER;
    }

    Token identifier() {
        while (isAlpha(this.peek()) || isDigit(this.peek())) {
            this.advance();
        }
        return this.token(this.identifierType());
    }

    bool match(String expected) {
        if (this.isAtEnd()) {
            return false;
        }
        if (this.source[this.current] != expected) {
            return false;
        }
        this.current += 1;
        return true;
    }

    Token string() {
        final stringType = this.peek(-1);

        while (this.peek() != stringType && !this.isAtEnd()) {
            if (this.peek() == '\n') {
                this.line += 1;
            }
            this.advance();
        }

        if (this.isAtEnd()) {
            return this.token(TokenType.COMPILER_ERROR);
        }

        // the closing quote
        this.advance();
        return this.token(TokenType.STRING);
    }

    Token scanToken() {
        this.skipWhitespace();

        this.lexemeStart = this.current;

        if (this.isAtEnd()) {
            return this.token(TokenType.EOF);
        }

        final ch = this.advance();

        if (isDigit(ch)) {
            return this.number();
        }

        if (isAlpha(ch)) {
            return this.identifier();
        }

        return switch (ch) {
            '(' => this.token(TokenType.PAREN_LEFT),
            ')' => this.token(TokenType.PAREN_RIGHT),
            '{' => this.token(TokenType.BRACE_LEFT),
            '}' => this.token(TokenType.BRACE_RIGHT),
            '[' => this.token(TokenType.BRACKET_LEFT),
            ']' => this.token(TokenType.BRACKET_RIGHT),
            ':' => this.token(TokenType.COLON),
            '@' => this.token(TokenType.ASTERISK),
            ';' => this.token(TokenType.SEMICOLON),
            ',' => this.token(TokenType.COMMA),
            '.' => this.token(TokenType.DOT),
            '-' => this.token(TokenType.MINUS),
            '+' => this.token(TokenType.PLUS),
            '/' => this.token(TokenType.SLASH),
            '*' => this.token(TokenType.ASTERISK),
            '?' => this.token(this.match('?') ? TokenType.NULL_FALLBACK : TokenType.QUESTION),
            '!' => this.token(this.match('=') ? TokenType.BANG_EQUAL : TokenType.BANG),
            '=' => this.token(this.match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL),
            '<' => this.token(this.match('=') ? TokenType.LESS_EQUAL : TokenType.LESS),
            '>' => this.token(this.match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER),
            '|' => this.token(this.match('|') ? TokenType.OR : TokenType.BIT_OR),
            '&' => this.token(this.match('&') ? TokenType.AND : TokenType.BIT_AND),
            '"' || "'" || '`' => this.string(),
            _ => this.token(TokenType.COMPILER_ERROR),
        };
    }

    List<Token> parseAll() {
        this.previous = null;
        List<Token> tokens = [];
        while (true) {
            final tok = this.scanToken();
            this.previous = tok;
            tokens.add(tok);
            if (tok.tokType == TokenType.COMPILER_ERROR || tok.tokType == TokenType.EOF) 
                break;
        }
        return tokens;
    }
}
