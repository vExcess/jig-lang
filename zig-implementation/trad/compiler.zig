const vexlib = @import("../lib/vexlib.zig");
const print = vexlib.print;
const println = vexlib.println;
const String = vexlib.String;
const Uint16Array = vexlib.Uint16Array;
const As = vexlib.As;
const Int = vexlib.Int;
const Float = vexlib.Float;

const utils = @import("./utils.zig");
const Chunk = utils.Chunk;
const ConstantPool = utils.ConstantPool;
const OpCode = utils.OpCode;
const Value = utils.Value;

const TokenType = enum {
    // tokens
    TILDE,
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    LEFT_BRACKET,
    RIGHT_BRACKET,
    COMMA,
    DOT,
    COLON,
    SEMICOLON,
    PLUS,
    PLUS_EQUAL,
    PLUS_PLUS,
    MINUS,
    MINUS_EQUAL,
    MINUS_MINUS,
    ASTERISK,
    ASTERISK_EQUAL,
    EXPONENT,
    EXPONENT_EQUAL,
    SLASH,
    SLASH_EQUAL,
    CARET,
    QUESTION,
    MODULUS,
    MODULUS_EQUAL,
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    ARROW,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,
    BIT_OR,
    OR,
    BIT_AND,
    AND,
    BIT_XOR,
    BITSHIFT_LEFT,
    BITSHIFT_RIGHT,
    UNSIGNED_BITSHIFT_RIGHT,

    CAST,

    // Literals
    IDENTIFIER,
    TEMPLATE_LITERAL,
    NUMBER,

    // Reserved Words
    FN,
    VAR,
    LET,
    CONST,
    IF,
    ELSE,
    DO,
    WHILE,
    FOR,
    STRUCT,
    CLASS,
    PRIVATE,
    STATIC,
    SUPER,
    EXTENDS,
    INHERIT,
    ENUM,
    TRY,
    CATCH,
    THROW,
    RETURN,
    SWITCH,
    CASE,
    DEFAULT,
    BREAK,
    CONTINUE,
    NEW,
    THIS,
    TRUE,
    FALSE,
    INFINITY,
    IMPORT,
    EXPORT,
    FROM,
    AS,
    ASYNC,
    AWAIT,
    TYPEOF,

    // data types keywords
    VOID,
    NULL,
    STRING,

    //temp
    PRINT,

    // for compiler
    COMPILER_ERROR,
    EOF,
};
const Token = struct { tokType: TokenType, start: u32, len: u32, line: u16 };

fn isDigit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}

fn isAlpha(ch: u8) bool {
    return (ch >= 'a' and ch <= 'z') or
        (ch >= 'A' and ch <= 'Z') or
        ch == '_';
}

const Tokenizer = struct {
    lexStart: u32 = undefined,
    current: u32 = undefined,
    line: u16 = undefined,
    source: String = undefined,

    fn init(source: String) Tokenizer {
        return Tokenizer{ .lexStart = 0, .current = 0, .line = 1, .source = source };
    }

    fn mkToken(self: *Tokenizer, tokType: TokenType) Token {
        return Token{ .tokType = tokType, .start = self.lexStart, .len = self.current - self.lexStart, .line = self.line };
    }

    fn isAtEnd(self: *Tokenizer) bool {
        return self.current >= self.source.len();
    }

    fn match(self: *Tokenizer, expected: u8) bool {
        if (self.isAtEnd()) {
            return false;
        }
        if (self.source.charAt(self.current) != expected) {
            return false;
        }
        self.current += 1;
        return true;
    }

    fn peek(self: *Tokenizer) u8 {
        return self.source.charAt(self.current);
    }

    fn peekAhead(self: *Tokenizer, offset: u32) u8 {
        if (self.current + offset >= self.source.len()) {
            return 0;
        }
        return self.source.charAt(self.current + offset);
    }

    fn advance(self: *Tokenizer) u8 {
        self.current += 1;
        return self.source.charAt(self.current - 1);
    }

    fn skipWhitespace(self: *Tokenizer) void {
        while (!self.isAtEnd()) {
            switch (self.peek()) {
                ' ', '\t', '\r' => {
                    _ = self.advance();
                },
                '\n' => {
                    self.line += 1;
                    _ = self.advance();
                },
                '/' => {
                    if (self.peekAhead(1) == '/') {
                        while (!self.isAtEnd() and self.peek() != '\n') {
                            _ = self.advance();
                        }
                    }
                },
                else => return,
            }
        }
    }

    fn string(self: *Tokenizer) Token {
        while (self.peek() != '"' and !self.isAtEnd()) {
            if (self.peek() == '\n') {
                self.line += 1;
            }
            _ = self.advance();
        }

        if (self.isAtEnd()) {
            return self.mkToken(TokenType.COMPILER_ERROR);
        }

        // the closing quote
        _ = self.advance();
        return self.mkToken(TokenType.STRING);
    }

    fn number(self: *Tokenizer) Token {
        while (isDigit(self.peek())) {
            _ = self.advance();
        }

        // look for fractional part
        if (self.peek() == '.' and isDigit(self.peekAhead(1))) {
            // consume the '.'
            _ = self.advance();

            while (isDigit(self.peek())) {
                _ = self.advance();
            }
        }

        return self.mkToken(TokenType.NUMBER);
    }

    fn checkKeyword(self: *Tokenizer, startOffset: u32, rest: []const u8) bool {
        const startIdx = self.lexStart + startOffset;
        var slc = self.source.slice(startIdx, startIdx + As.u32(rest.len));
        return slc.equals(rest);
    }

    fn identifierType(self: *Tokenizer) TokenType {
        switch (self.source.charAt(self.lexStart)) {
            'a' => {
                if (self.checkKeyword(1, "nd")) {
                    return TokenType.AND;
                }
            },
            'c' => {
                if (self.checkKeyword(1, "lass")) {
                    return TokenType.CLASS;
                }
            },
            'e' => {
                if (self.checkKeyword(1, "lse")) {
                    return TokenType.ELSE;
                }
            },
            'f' => {
                if (self.current - self.lexStart > 1) {
                    switch (self.source.charAt(self.lexStart + 1)) {
                        'a' => {
                            if (self.checkKeyword(2, "lse")) {
                                return TokenType.FALSE;
                            }
                        },
                        'o' => {
                            if (self.checkKeyword(2, "r")) {
                                return TokenType.FOR;
                            }
                        },
                        'u' => {
                            if (self.checkKeyword(2, "n")) {
                                return TokenType.FN;
                            }
                        },
                        else => {},
                    }
                }
            },
            'i' => {
                if (self.checkKeyword(1, "f")) {
                    return TokenType.IF;
                }
            },
            'n' => {
                if (self.checkKeyword(1, "ull")) {
                    return TokenType.NULL;
                }
            },
            'o' => {
                if (self.checkKeyword(1, "r")) {
                    return TokenType.OR;
                }
            },
            'p' => {
                if (self.checkKeyword(1, "rint")) {
                    return TokenType.PRINT;
                }
            },
            'r' => {
                if (self.checkKeyword(1, "eturn")) {
                    return TokenType.RETURN;
                }
            },
            's' => {
                if (self.checkKeyword(1, "uper")) {
                    return TokenType.SUPER;
                }
            },
            't' => {
                if (self.current - self.lexStart > 1) {
                    switch (self.source.charAt(self.lexStart + 1)) {
                        'h' => {
                            if (self.checkKeyword(2, "is")) {
                                return TokenType.THIS;
                            }
                        },
                        'r' => {
                            if (self.checkKeyword(2, "ue")) {
                                return TokenType.TRUE;
                            }
                        },
                        else => {},
                    }
                }
            },
            'v' => {
                if (self.checkKeyword(1, "var")) {
                    return TokenType.VAR;
                }
            },
            'w' => {
                if (self.checkKeyword(1, "hile")) {
                    return TokenType.WHILE;
                }
            },
            else => {},
        }

        return TokenType.IDENTIFIER;
    }

    fn identifier(self: *Tokenizer) Token {
        while (isAlpha(self.peek()) or isDigit(self.peek())) {
            _ = self.advance();
        }
        return self.mkToken(self.identifierType());
    }

    fn scanToken(self: *Tokenizer) Token {
        self.skipWhitespace();

        self.lexStart = self.current;

        if (self.isAtEnd()) {
            return self.mkToken(TokenType.EOF);
        }

        const ch = self.advance();

        if (isDigit(ch)) {
            return self.number();
        }

        if (isAlpha(ch)) {
            return self.identifier();
        }

        return switch (ch) {
            '(' => self.mkToken(TokenType.LEFT_PAREN),
            ')' => self.mkToken(TokenType.RIGHT_PAREN),
            '{' => self.mkToken(TokenType.LEFT_BRACE),
            '}' => self.mkToken(TokenType.RIGHT_BRACE),
            ';' => self.mkToken(TokenType.SEMICOLON),
            ',' => self.mkToken(TokenType.COMMA),
            '.' => self.mkToken(TokenType.DOT),
            '-' => self.mkToken(TokenType.MINUS),
            '+' => self.mkToken(TokenType.PLUS),
            '/' => self.mkToken(TokenType.SLASH),
            '*' => self.mkToken(TokenType.ASTERISK),
            '!' => self.mkToken(if (self.match('=')) TokenType.BANG_EQUAL else TokenType.BANG),
            '=' => self.mkToken(if (self.match('=')) TokenType.EQUAL_EQUAL else TokenType.EQUAL),
            '<' => self.mkToken(if (self.match('=')) TokenType.LESS_EQUAL else TokenType.LESS),
            '>' => self.mkToken(if (self.match('=')) TokenType.GREATER_EQUAL else TokenType.GREATER),
            '"' => self.string(),
            else => self.mkToken(TokenType.COMPILER_ERROR),
        };
    }
};

const Parser = struct {
    tokenizer: *Tokenizer = undefined,
    current: Token = undefined,
    previous: Token = undefined,
    hadError: bool = undefined,
    panicMode: bool = undefined,

    fn init(tokenizer: *Tokenizer) Parser {
        return Parser{ .tokenizer = tokenizer, .current = undefined, .previous = undefined, .hadError = false, .panicMode = false };
    }

    fn getRawLexeme(self: *Parser, tok: Token) []const u8 {
        var source = self.tokenizer.source;
        var slc = source.slice(tok.start, tok.start + tok.len);
        const rawSlc = slc.raw();
        return rawSlc;
    }

    fn advance(self: *Parser) void {
        self.previous = self.current;

        while (true) {
            self.current = self.tokenizer.scanToken();
            print("TOK: ");
            println(self.current);
            if (self.current.tokType != TokenType.COMPILER_ERROR) {
                break;
            }

            self.errAtCurr(self.getRawLexeme(self.current));
        }
    }

    fn consume(self: *Parser, tokType: TokenType, message: []const u8) void {
        if (self.current.tokType == tokType) {
            self.advance();
            return;
        }

        self.errAtCurr(message);
    }

    fn errorAt(self: *Parser, token: Token, msg: []const u8) void {
        if (self.panicMode) {
            return;
        }
        self.panicMode = true;
        print("line ");
        print(token.line);
        print("Error");

        if (token.tokType == TokenType.EOF) {
            print(" at end");
        } else if (token.tokType == TokenType.COMPILER_ERROR) {
            // Nothing.
        } else {
            print(" at ");
            print(token.len);
            print(token.start);
        }

        println(msg);
        self.hadError = true;
    }

    fn errAtPrev(self: *Parser, message: []const u8) void {
        self.errorAt(self.previous, message);
    }

    fn errAtCurr(self: *Parser, message: []const u8) void {
        self.errorAt(self.current, message);
    }
};

const Precedence = enum(u8) {
    NONE,
    ASSIGNMENT, // =
    OR, // or
    AND, // and
    EQUALITY, // == !=
    COMPARISON, // < > <= >=
    TERM, // + -
    FACTOR, // * /
    UNARY, // ! -
    CALL, // . ()
    PRIMARY,
};

const ParseFn = *const fn (*Compiler) void;

const ParseRule = struct { prefixFn: ?ParseFn, infixFn: ?ParseFn, precedence: Precedence };

fn grouping() void {}

var initedParserRules = false;
var parserRules: [@typeInfo(TokenType).Enum.fields.len]ParseRule = undefined;
fn initParserRules() void {
    const rule = struct {
        inline fn func(tok: TokenType, prefixFn: ?ParseFn, infixFn: ?ParseFn, precedence: Precedence) void {
            parserRules[@intFromEnum(tok)] = ParseRule{ .prefixFn = prefixFn, .infixFn = infixFn, .precedence = precedence };
        }
    }.func;

    rule(.LEFT_PAREN, Compiler.grouping, null, .NONE);
    rule(.RIGHT_PAREN, null, null, .NONE);
    rule(.LEFT_BRACE, null, null, .NONE);
    rule(.RIGHT_BRACE, null, null, .NONE);
    rule(.COMMA, null, null, .NONE);
    rule(.DOT, null, null, .NONE);
    rule(.MINUS, Compiler.unary, Compiler.binary, .TERM);
    rule(.PLUS, null, Compiler.binary, .TERM);
    rule(.SEMICOLON, null, null, .NONE);
    rule(.SLASH, null, Compiler.binary, .FACTOR);
    rule(.ASTERISK, null, Compiler.binary, .FACTOR);
    rule(.BANG, Compiler.unary, null, .NONE);
    rule(.BANG_EQUAL, null, Compiler.binary, .EQUALITY);
    rule(.EQUAL, null, null, .NONE);
    rule(.EQUAL_EQUAL, null, Compiler.binary, .EQUALITY);
    rule(.GREATER, null, Compiler.binary, .COMPARISON);
    rule(.GREATER_EQUAL, null, Compiler.binary, .COMPARISON);
    rule(.LESS, null, Compiler.binary, .COMPARISON);
    rule(.LESS_EQUAL, null, Compiler.binary, .COMPARISON);
    rule(.IDENTIFIER, null, null, .NONE);
    rule(.STRING, Compiler.string, null, .NONE);
    rule(.NUMBER, Compiler.number, null, .NONE);
    rule(.AND, null, null, .NONE);
    rule(.CLASS, null, null, .NONE);
    rule(.ELSE, null, null, .NONE);
    rule(.FALSE, Compiler.literal, null, .NONE);
    rule(.FOR, null, null, .NONE);
    rule(.FN, null, null, .NONE);
    rule(.IF, null, null, .NONE);
    rule(.NULL, Compiler.literal, null, .NONE);
    rule(.OR, null, null, .NONE);
    rule(.PRINT, null, null, .NONE);
    rule(.RETURN, null, null, .NONE);
    rule(.SUPER, null, null, .NONE);
    rule(.THIS, null, null, .NONE);
    rule(.TRUE, Compiler.literal, null, .NONE);
    rule(.VAR, null, null, .NONE);
    rule(.WHILE, null, null, .NONE);
    rule(.COMPILER_ERROR, null, null, .NONE);
    rule(.EOF, null, null, .NONE);

    initedParserRules = true;
}

pub const Compiler = struct {
    compilingChunk: *Chunk,
    compilingLines: *Uint16Array,
    constantPool: *ConstantPool,
    parser: *Parser,

    pub fn init() Compiler {
        if (!initedParserRules) {
            initParserRules();
        }
        return Compiler{
            .compilingChunk = undefined,
            .compilingLines = undefined,
            .constantPool = undefined,
            .parser = undefined,
        };
    }

    fn emitByte(self: *Compiler, byte: u8) void {
        self.compilingChunk.append(byte);
        self.compilingLines.append(self.parser.previous.line);
    }

    fn emitOp(self: *Compiler, op: OpCode) void {
        self.compilingChunk.append(@intFromEnum(op));
        self.compilingLines.append(self.parser.previous.line);
    }

    fn emitOpByte(self: *Compiler, op: OpCode, byte: u8) void {
        self.emitOp(op);
        self.emitByte(byte);
    }

    fn addConstant(self: *Compiler, val: Value) void {
        self.constantPool.append(val);
        const poolIdx = self.constantPool.len - 1;
        if (poolIdx > 255) {
            @panic("Too many constants in chunk");
        }
        self.emitOpByte(.CONST, As.u8T(poolIdx));
    }

    fn number(self: *Compiler) void {
        const slcStart = self.parser.previous.start;
        const slcLen = self.parser.previous.len;
        const numStr = self.parser.tokenizer.source.slice(slcStart, slcStart + slcLen);
        const val = As.f32(Int.parse(numStr, 10));
        self.addConstant(Value{ .F32 = val });
    }

    fn string(self: *Compiler) void {
        const slcStart = self.parser.previous.start + 1;
        const slcLen = self.parser.previous.len - 2;
        const slc = self.parser.tokenizer.source.slice(slcStart, slcStart + slcLen);
        self.addConstant(Value{ .STRING = String.newFrom(slc) });
    }

    fn grouping(self: *Compiler) void {
        self.expression();
        self.parser.consume(TokenType.RIGHT_PAREN, "Expect ')' after expression");
    }

    fn unary(self: *Compiler) void {
        const operatorType = self.parser.previous.tokType;

        // compile the operand
        self.parsePrecedence(Precedence.UNARY);

        // Emit the operator instruction
        switch (operatorType) {
            .MINUS => {
                self.emitOp(.NEG);
            },
            .BANG => {
                self.emitOp(.NOT);
            },
            else => unreachable,
        }
    }

    fn parsePrecedence(self: *Compiler, precedence: Precedence) void {
        var parser = self.parser;
        parser.advance();
        const prefixRule = self.getRule(parser.previous.tokType).prefixFn;
        if (prefixRule) |ruleFn| {
            ruleFn(self);
            while (@intFromEnum(precedence) <= @intFromEnum(self.getRule(parser.current.tokType).precedence)) {
                parser.advance();
                const infixRule = self.getRule(parser.previous.tokType).infixFn;
                infixRule.?(self);
            }
        } else {
            parser.errAtPrev("Expect expression.");
            return;
        }
    }

    fn getRule(self: *Compiler, tokType: TokenType) *ParseRule {
        _ = self;
        return &parserRules[@intFromEnum(tokType)];
    }

    fn expression(self: *Compiler) void {
        self.parsePrecedence(Precedence.ASSIGNMENT);
    }

    fn binary(self: *Compiler) void {
        const operatorType = self.parser.previous.tokType;
        const rule = self.getRule(operatorType);
        self.parsePrecedence(@as(Precedence, @enumFromInt(@intFromEnum(rule.precedence) + 1)));
        switch (operatorType) {
            .PLUS => {
                self.emitOp(.ADD);
            },
            .MINUS => {
                self.emitOp(.SUB);
            },
            .ASTERISK => {
                self.emitOp(.MUL);
            },
            .SLASH => {
                self.emitOp(.DIV);
            },
            .BANG_EQUAL => {
                self.emitOp(.NEQ);
            },
            .EQUAL_EQUAL => {
                self.emitOp(.EQ);
            },
            .GREATER => {
                self.emitOp(.GT);
            },
            .GREATER_EQUAL => {
                self.emitOp(.GTE);
            },
            .LESS => {
                self.emitOp(.LT);
            },
            .LESS_EQUAL => {
                self.emitOp(.LTE);
            },
            else => unreachable,
        }
    }

    fn literal(self: *Compiler) void {
        // seperate functions as compiler optimization?
        switch (self.parser.previous.tokType) {
            .FALSE => self.emitOp(.FALSE),
            .NULL => self.emitOp(.NULL),
            .TRUE => self.emitOp(.TRUE),
            else => unreachable,
        }
    }

    pub fn compile(self: *Compiler, source_: String, chunk: *Chunk, lines: *Uint16Array, pool: *ConstantPool) bool {
        var tokenizer = Tokenizer.init(source_);
        var parser = Parser.init(&tokenizer);

        // var source = source_;
        // var line: u16 = 0;
        // while (true) {
        //     const token = tokenizer.scanToken();
        //     if (token.tokType != TokenType.COMPILER_ERROR) {
        //         if (token.line != line) {
        //             print(token.line);
        //             line = token.line;
        //         } else {
        //             print("|");
        //         }
        //         print(" ");
        //         print(source.slice(token.start, token.start + token.len));
        //         print(" ");
        //         print(token.len);
        //         print(" ");
        //         println(token.start);
        //     } else {
        //         return false;
        //     }
        // }

        // ----------------------------
        self.compilingChunk = chunk;
        self.compilingLines = lines;
        self.constantPool = pool;
        self.parser = &parser;

        parser.advance();
        self.expression();
        println("\n\n\n\n");
        parser.consume(TokenType.EOF, "Expected EOF");
        self.emitOp(.RETURN);
        return !parser.hadError;
    }
};
