
enum TokenType {
    // tokens
    TILDE,
    PAREN_LEFT,
    PAREN_RIGHT,
    BRACE_LEFT,
    BRACE_RIGHT,
    BRACKET_LEFT,
    BRACKET_RIGHT,
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
    NULL_FALLBACK,
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
    TYPE_IDENTIFIER,
    NUMBER,

    // Reserved Words
    FN,
    VAR,
    LET,
    CONST,
    TYPEDEF,
    IF,
    IN,
    IS,
    OF,
    ELSE,
    DO,
    WHILE,
    FOR,
    STRUCT,
    CLASS,
    STATIC,
    PRIVATE,
    SUPER,
    EXTENDS,
    INHERIT,
    ENUM,
    TRY,
    CATCH,
    RETURN,
    SWITCH,
    CASE,
    BREAK,
    CONTINUE,
    NEW,
    TRUE,
    FALSE,
    INFINITY,
    IMPORT,
    EXPORT,
    FROM,
    HIDE,
    AS,
    ASYNC,
    AWAIT,

    // data types keywords
    VOID,
    NULL,
    STRING,

    //temp
    PRINT,

    // for compiler
    COMPILER_ERROR,
    EOF,
}

class Token {
    TokenType tokType;
    int start;
    String lexeme;
    int line;
    Token(this.tokType, this.start, this.lexeme, this.line);

    @override
    String toString([bool hideLinePos=false]) {
        return "Token(${tokType.toString().substring("TokenType.".length)} `${lexeme}`${hideLinePos ? "" : " ${start},${line}"})";
    }
}

enum FunctionType {
    NONE,
    FUNCTION,
    METHOD,
    INITIALIZER
}

enum ClassType {
    NONE,
    CLASS
}