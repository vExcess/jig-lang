import 'Token.dart';
import 'parser.dart';

enum IType {
    Bool,
    String,
    Int,
    Double,
    Null
}

class IValue {
    IType type;
    Object value;

    IValue(this.type, this.value);

    String toString() {
        if (type == IType.Null) return "null";

        if (type == IType.Double) {
            String text = value.toString();
            if (text.endsWith(".0")) {
                text = text.substring(0, text.length - 2);
            }
            return text;
        }

        return value.toString();
    }
}

class Environment {
    Environment? parent = null;
    Map<String, IValue?> values = {};

    Environment([this.parent]);

    IValue? get(String name) {
        if (values.containsKey(name)) {
            return values[name];
        }
        if (parent != null) {
            return parent!.get(name);
        }
        throw "Undefined variable '" + name + "'.";
    }

    void set(String name, IValue? val) {
        if (values.containsKey(name)) {
            values[name] = val;
            return;
        }
        if (parent != null) {
            return parent!.set(name, val);
        }
        throw "Undefined variable '" + name + "'.";
    }

    void define(String name, IValue? val) {
        values[name] = val;
    }
}


class Interpreter {
    Environment environment = new Environment();

    bool hadRuntimeError = false;

    IValue evaluate(Expr expr) {
        if (expr is LiteralExpr) {
            final tok = expr.token;
            if (tok.tokType == TokenType.NULL) {
                return IValue(IType.Null, 0);
            }
            if (tok.tokType == TokenType.NUMBER) {
                return IValue(IType.Double, double.parse(tok.lexeme));
            }
            if (tok.tokType == TokenType.STRING) {
                return IValue(IType.String, tok.lexeme);
            }
            if (tok.lexeme == "true") {
                return IValue(IType.Bool, true);
            }
            if (tok.lexeme == "false") {
                return IValue(IType.Bool, false);
            }
        }
        if (expr is BinaryExpr) {
            return visitBinaryExpr(expr);
        }
        if (expr is GroupingExpr) {
            return evaluate(expr.expression);
        }
        if (expr is UnaryExpr) {
            IValue right = evaluate(expr.right);

            switch (expr.operator.tokType) {
                case TokenType.BANG:
                    return IValue(right.type, !isTruthy(right));
                case TokenType.MINUS:
                    checkNumberOperand(expr.operator, right);
                    return IValue(right.type, -(right.value as double));
                default:

            }

            throw "unreachable UnaryExpr";
        }
        if (expr is VariableExpr) {
            final val = environment.get(expr.nameToken.lexeme);
            if (val == null) {
                throw "variable ${expr.nameToken.lexeme} must be initialized before use";
            }
            return val;
        }
        if (expr is AssignmentExpr) {
            IValue value = evaluate(expr.expr);
            environment.set(expr.nameToken.lexeme, value);
            return value;
        }
        throw "unreachable ${expr.toString()}";
    }

    void executeStatement(Stmt stmt){
        if (stmt is ExpressionStmt) {
            evaluate(stmt.expr);
        }

        if (stmt is IfStmt) {
            if (isTruthy(evaluate(stmt.condition))) {
                executeStatement(stmt.thenBranch);
            } else if (stmt.elseBranch != null) {
                executeStatement(stmt.elseBranch!);
            }
        }

        if (stmt is WhileStmt) {
            while (isTruthy(evaluate(stmt.condition))) {
                executeStatement(stmt.body);
            }
        }

        if (stmt is BlockStmt) {
            Environment previous = this.environment;
            try {
                this.environment = new Environment(environment);

                for (final statement in stmt.stmts) {
                    executeStatement(statement);
                }
            } finally {
                this.environment = previous;
            }
        }

        if (stmt is PrintStmt) {
            IValue value = evaluate(stmt.expr);
            print(value.toString());
        }

        if (stmt is VariableStmt) {
            IValue? value = null;
            if (stmt.expr != null) {
                value = evaluate(stmt.expr!);
            }
            environment.define(stmt.name.lexeme, value);
        }
    }

    IValue visitBinaryExpr(BinaryExpr expr) {
        IValue left = evaluate(expr.left);

        if (expr.operator.tokType == TokenType.AND) {
            if (!isTruthy(left)) {
                return IValue(IType.Bool, false);
            }
            IValue right = evaluate(expr.right);
            return IValue(IType.Bool, isTruthy(right));
        } else if (expr.operator.tokType == TokenType.NULL_FALLBACK) {
            if (left.type == IType.Null) {
                return evaluate(expr.right);
            }
            return left;
        } else {
            IValue right = evaluate(expr.right); 

            switch (expr.operator.tokType) {
                case TokenType.MINUS:
                    checkNumberOperands(expr.operator, left, right);
                    return IValue(IType.Double, (left.value as double) - (right.value as double));
                case TokenType.PLUS:
                    if (left.type == IType.Double && right.type == IType.Double) {
                        return IValue(IType.Double, (left.value as double) + (right.value as double));
                    } 
                    if (left.type == IType.String && right.type == IType.String) {
                        return IValue(IType.Double, (left.value as String) + (right.value as String));
                    }
                    throw (expr.operator, "Operands must be two numbers or two strings.");
                case TokenType.SLASH:
                    checkNumberOperands(expr.operator, left, right);
                    return IValue(IType.Double, (left.value as double) / (right.value as double));
                case TokenType.ASTERISK:
                    checkNumberOperands(expr.operator, left, right);
                    return IValue(IType.Double, (left.value as double) * (right.value as double));
                case TokenType.GREATER:
                    checkNumberOperands(expr.operator, left, right);
                    return IValue(IType.Bool, (left.value as double) > (right.value as double));
                case TokenType.GREATER_EQUAL:
                    checkNumberOperands(expr.operator, left, right);
                    return IValue(IType.Bool, (left.value as double) >= (right.value as double));
                case TokenType.LESS:
                    checkNumberOperands(expr.operator, left, right);
                    return IValue(IType.Bool, (left.value as double) < (right.value as double));
                case TokenType.LESS_EQUAL:
                    checkNumberOperands(expr.operator, left, right);
                    return IValue(IType.Bool, (left.value as double) <= (right.value as double));
                case TokenType.BANG_EQUAL:
                    return IValue(IType.Bool, !isEqual(left, right));
                case TokenType.EQUAL_EQUAL:
                    return IValue(IType.Bool, isEqual(left, right));
                case TokenType.OR:
                    return IValue(IType.Bool, isTruthy(left) || isTruthy(right));

                default:
            }

            throw "unreachable BinaryExpr ${left} ${expr.operator} ${right}";
        }
    }

    bool isTruthy(IValue object) {
        if (object.type == IType.Null) return false;
        if (object.type == IType.Bool) return object.value as bool;
        return true;
    }

    bool isEqual(IValue a, IValue b) {
        return a.type == b.type && a.value == b.value;
    }

    void checkNumberOperand(Token operator, IValue operand) {
        if (operand.type == IType.Double) return;
        throw (operator, "Operand must be a number.");
    }

    void checkNumberOperands(Token operator, IValue left, IValue right) {
        if (left.type == IType.Double && right.type == IType.Double) return;
        throw (operator, "Operands must be numbers.");
    }

    void interpret(List<Stmt> statements) { 
        try {
            for (final stmt in statements) {
                executeStatement(stmt);
            }
            
        } catch (jigErr) {
            print(jigErr);
            // final err = jigErr as (Token, String);
            // print(err.$2 +
            //     "\n[line ${err.$1.line}]");
            // hadRuntimeError = true;
        }
    }
}