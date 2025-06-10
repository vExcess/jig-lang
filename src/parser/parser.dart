import '../data/Token.dart';
import '../data/Expr.dart';
import '../data/Stmt.dart';

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

    void error(Token tok, String msg) {
        print(tok);
        print(msg);
    }

    // ===== =====

    Stmt statement() {
        // print("statement " + getLexemes());
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
                consume(TokenType.PAREN_RIGHT, "Expected ')' after while condition."); 
            }
            
            return new WhileStmt(condition, statement());
        }

        if (match([TokenType.FOR])) {
            final usesParenthesis = match([TokenType.PAREN_LEFT]);
            Stmt? initializer;
            Expr? condition;
            Expr? increment;
            if (!match([TokenType.SEMICOLON])) {
                initializer = statement();
                consume(TokenType.SEMICOLON, "Expected ';' after for initializer."); 
            }
            if (!match([TokenType.SEMICOLON])) {
                condition = expression();
                consume(TokenType.SEMICOLON, "Expected ';' after for condition."); 
            }
            if (!check(TokenType.SEMICOLON)) {
                increment = expression();
            }
            if (usesParenthesis) {
                consume(TokenType.PAREN_RIGHT, "Expected ')' after for header."); 
            }
            Stmt body = statement();
            if (increment != null) {
                body = new BlockStmt([body, new ExpressionStmt(increment)]);
            }

            if (condition == null) {
                condition = new LiteralExpr(new Token(TokenType.TRUE, 0, "true", 0));
            }
            Stmt whileLoop = new WhileStmt(condition, body);
            if (initializer != null) {
                whileLoop = new BlockStmt([initializer, whileLoop]);
            }
            return whileLoop;
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

        if (match([TokenType.RETURN])) {
            Token keyword = previous();
            Expr? value = null;
            if (!check(TokenType.SEMICOLON) && !check(TokenType.BRACE_RIGHT)) {
                value = expression();
            }
            return new ReturnStmt(value, keyword);
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
        // print("expression " + getLexemes());
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
        return call();
    }
    
    Expr call() {
        Expr expr = primary();

        while (true) { 
            if (match([TokenType.PAREN_LEFT])) {
                List<Expr> arguments = [];
                if (!check(TokenType.PAREN_RIGHT)) {
                    do {
                        // limit is 254 to account for "this" argument
                        if (arguments.length >= 255) {
                            error(peek(), "Can't have more than 255 arguments.");
                        }
                        arguments.add(expression());
                    } while (match([TokenType.COMMA]));
                }

                Token paren = consume(TokenType.PAREN_RIGHT, "Expect ')' after arguments.");
                expr = new CallExpr(expr, arguments, {}, paren);
            } else {
                break;
            }
        }

        return expr;
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

        print("expression1 " + getLexemes());
        if (match([TokenType.FN])) {
            print("expression2 " + getLexemes());
            String kind = "function";
            Token name = consume(TokenType.IDENTIFIER, "Expect ${kind} name.");
            consume(TokenType.PAREN_LEFT, "Expect '(' after " + kind + " name.");
            List<Token> parameters = [];
            if (!check(TokenType.PAREN_RIGHT)) {
                do {
                    // limit is 254 for "this" argument
                    if (parameters.length >= 255) {
                        error(peek(), "Can't have more than 255 parameters.");
                    }
                    parameters.add(consume(TokenType.IDENTIFIER, "Expect parameter name."));
                } while (match([TokenType.COMMA]));
            }
            consume(TokenType.PAREN_RIGHT, "Expect ')' after parameters.");
            
            consume(TokenType.BRACE_LEFT, "Expect '{' before " + kind + " body.");
            List<Stmt> body = block();
            return new FunctionExpr(name, parameters, body);

        }

        throw (peek(), "err in primary");
    }

    String getLexemes() {
        return tokens.sublist(current).map((tok) {
            return "`${tok.lexeme}`";
        }).join(', ');
    }
}

