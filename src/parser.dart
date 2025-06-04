import 'Token.dart';

class Expr {}

class BinaryExpr extends Expr {
    Expr left;
    Token operator;
    Expr right;
    BinaryExpr(this.left, this.operator, this.right);
}

class GroupingExpr extends Expr {
    Expr expression;
    GroupingExpr(this.expression);
}

class UnaryExpr extends Expr {
    Token operator;
    Expr right;
    UnaryExpr(this.operator, this.right);
}

class LiteralExpr extends Expr {
    Token token;
    LiteralExpr(this.token);
}

class VariableExpr extends Expr {
    Token nameToken;
    VariableExpr(this.nameToken);
}

class AssignmentExpr extends Expr {
    Token nameToken; 
    Expr expr;
    AssignmentExpr(this.nameToken, this.expr);
}

enum StmtType {
    EXPRESSION,
    PRINT
}

class Stmt {}

class ExpressionStmt extends Stmt {
    Expr expr;
    ExpressionStmt(this.expr);
}

class BlockStmt extends Stmt {
    List<Stmt> stmts;
    BlockStmt(this.stmts);
}

class PrintStmt extends Stmt {
    Expr expr;
    PrintStmt(this.expr);
}

class VariableStmt extends Stmt {
    TokenType varType;
    Token name;
    Expr? expr;
    VariableStmt(this.varType, this.name, this.expr);
}

class IfStmt extends Stmt {
    Expr condition;
    Stmt thenBranch;
    Stmt? elseBranch;
    IfStmt(this.condition, this.thenBranch, this.elseBranch);
}

class WhileStmt extends Stmt {
    Expr condition;
    Stmt body;
    WhileStmt(this.condition, this.body);
}

class Parser {
    List<Token> tokens;
    int current = 0;

    Parser(this.tokens);

    List<Stmt> parse() {
        List<Stmt> statements = [];
        while (!isAtEnd()) {
            statements.add(statement());
            match([TokenType.SEMICOLON]);
        }
        return statements;
    }

    // ===== Utility methods =====

    bool isAtEnd() {
        return current >= tokens.length || peek().tokType == TokenType.EOF;
    }

    Token peek([int amt=0]) {
        return this.tokens[current + amt];
    }

    Token previous() {
        return this.tokens[current - 1];
    }

    Token advance() {
        if (!isAtEnd()) current++;
        return previous();
    }

    bool check(TokenType type) {
        if (isAtEnd()) return false;
        return peek().tokType == type;
    }

    bool match(List<TokenType> types) {
        // matches any of a list of types
        for (final type in types) {
            if (check(type)) {
                advance();
                return true;
            }
        }
        return false;
    }

    Token consume(TokenType type, String message) {
        if (check(type)) return advance();
        throw (peek(), message);
    }

    // ===== =====

    Stmt statement() {
        if (match([TokenType.PRINT])) {
            return new PrintStmt(expression());
        }

        if (match([TokenType.BRACE_LEFT])) {
            return new BlockStmt(block());
        }

        if (match([TokenType.IF])) {
            final usesParenthesis = match([TokenType.PAREN_LEFT]);
            Expr condition = expression();
            if (usesParenthesis) {
                consume(TokenType.PAREN_RIGHT, "Expected ')' after if condition."); 
            }

            Stmt thenBranch = statement();
            Stmt? elseBranch = null;
            if (match([TokenType.ELSE])) {
                elseBranch = statement();
            }

            return new IfStmt(condition, thenBranch, elseBranch);
        }

        if (match([TokenType.WHILE])) {
            final usesParenthesis = match([TokenType.PAREN_LEFT]);
            Expr condition = expression();
            if (usesParenthesis) {
                consume(TokenType.PAREN_RIGHT, "Expected ')' after if condition."); 
            }
            
            return new WhileStmt(condition, statement());
        }

        if (match([TokenType.VAR, TokenType.LET, TokenType.CONST])) {
            final varType = previous().tokType;
            Token name = consume(TokenType.IDENTIFIER, "Expect variable name.");

            Expr? initializer = null;
            if (match([TokenType.EQUAL])) {
                initializer = expression();
            }

            return new VariableStmt(varType, name, initializer);
        }

        return new ExpressionStmt(expression());
    }

    List<Stmt> block() {
        List<Stmt> statements = [];

        while (!check(TokenType.BRACE_RIGHT) && !isAtEnd()) {
            statements.add(statement());
            match([TokenType.SEMICOLON]);
        }

        consume(TokenType.BRACE_RIGHT, "Expect '}' after block.");
        return statements;
    }

    Expr expression() {
        final expr = operatorPrec0();

        if (match([TokenType.EQUAL])) {
            final val = expression();
            if (expr is VariableExpr) {
                Token name = expr.nameToken;
                return new AssignmentExpr(name, val);
            }
            throw "Invalid assignment target.";
        }
        
        return expr;
    }

    Expr operatorPrec0() {
        // print("operatorPrec0 " + getLexemes());
        var expr = operatorPrec1();
        while (match([TokenType.OR, TokenType.NULL_FALLBACK])) {
            final operator = previous();
            final right = operatorPrec1();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec1() {
        // print("operatorPrec1 " + getLexemes());
        var expr = operatorPrec2();
        while (match([TokenType.AND])) {
            final operator = previous();
            final right = operatorPrec2();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec2() {
        // print("operatorPrec2 " + getLexemes());
        var expr = operatorPrec3();
        while (match([TokenType.BIT_OR])) {
            final operator = previous();
            final right = operatorPrec3();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec3() {
        // print("operatorPrec3 " + getLexemes());
        var expr = operatorPrec4();
        while (match([TokenType.BIT_XOR])) {
            final operator = previous();
            final right = operatorPrec4();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec4() {
        // print("operatorPrec4 " + getLexemes());
        var expr = operatorPrec5();
        while (match([TokenType.BIT_AND])) {
            final operator = previous();
            final right = operatorPrec5();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec5() {
        // print("operatorPrec5 " + getLexemes());
        var expr = operatorPrec6();
        while (match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
            final operator = previous();
            final right = operatorPrec6();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec6() {
        // print("operatorPrec6 " + getLexemes());
        var expr = operatorPrec7();
        while (match([TokenType.GREATER, TokenType.GREATER_EQUAL, TokenType.LESS, TokenType.LESS_EQUAL, TokenType.IN, TokenType.IS])) {
            final operator = previous();
            final right = operatorPrec7();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec7() {
        // print("operatorPrec7 " + getLexemes());
        var expr = operatorPrec8();
        while (match([TokenType.BITSHIFT_LEFT, TokenType.BITSHIFT_RIGHT])) {
            final operator = previous();
            final right = operatorPrec8();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec8() {
        // print("operatorPrec8 " + getLexemes());
        var expr = operatorPrec9();
        while (match([TokenType.MINUS, TokenType.PLUS])) {
            final operator = previous();
            final right = operatorPrec9();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec9() {
        // print("operatorPrec9 " + getLexemes());
        var expr = operatorPrec10();
        while (match([TokenType.SLASH, TokenType.ASTERISK, TokenType.MODULUS])) {
            final operator = previous();
            final right = operatorPrec10();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr operatorPrec10() {
        // print("operatorPrec10 " + getLexemes());
        var expr = unary();
        while (match([TokenType.EXPONENT])) {
            final operator = previous();
            final right = unary();
            expr = BinaryExpr(expr, operator, right);
        }
        return expr;
    }
    Expr unary() {
        // print("unary " + getLexemes());
        if (match([TokenType.BANG, TokenType.MINUS, TokenType.CAST, TokenType.PLUS_PLUS, TokenType.MINUS_MINUS, TokenType.TILDE, TokenType.PLUS, TokenType.AWAIT])) {
            Token operator = previous();
            Expr right = unary();
            return new UnaryExpr(operator, right);
        }
        return primary();
    }
    Expr primary() {
        // print("primary " + getLexemes());
        if (match([TokenType.FALSE, TokenType.TRUE, TokenType.NULL, TokenType.NUMBER, TokenType.STRING])) {
            return new LiteralExpr(previous());
        }

        if (match([TokenType.IDENTIFIER])) {
            return new VariableExpr(previous());
        }

        if (match([TokenType.PAREN_LEFT])) {
            Expr expr = expression();
            consume(TokenType.PAREN_RIGHT, "Expect ')' after expression.");
            return new GroupingExpr(expr);
        }

        throw (peek(), "err in primary");
    }

    String getLexemes() {
        return tokens.sublist(current).map((tok) {
            return "`${tok.lexeme}`";
        }).join(', ');
    }
}

