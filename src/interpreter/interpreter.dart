import '../data/Token.dart';
import '../data/Expr.dart';
import '../data/Stmt.dart';
import 'Resolver.dart';

dynamic LOG(Object? data) {
    print("  $data");
    return data;
}

enum IType {
    Bool,
    String,
    Int,
    Double,
    Null,
    Function
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

class JigFunction {
    IValue Function(Interpreter interpreter, List<IValue> arguments)? nativeFn;
    FunctionExpr? jigFn;
    Environment closure;

    JigFunction(Object func, this.closure) {
        if (func is FunctionExpr) {
            this.jigFn = func;
        } else {
            this.nativeFn = func as IValue Function(Interpreter interpreter, List<IValue> arguments);
        }
    }

    IValue call(Interpreter interpreter, List<IValue> arguments) {
        if (jigFn != null) {
            Environment environment = new Environment(closure);
            for (int i = 0; i < jigFn!.params.length; i++) {
                environment.define(
                    jigFn!.params[i].lexeme,
                    arguments[i]
                );
            }

            IValue? res = interpreter.executeInNewScope(jigFn!.body, environment);
            if (res != null) {
                return res;
            }
            return new IValue(IType.Null, 0);
        } else {
            return nativeFn!(interpreter, arguments);
        }
    }

    String toString() {
        if (jigFn != null) {
            return "<fn ${jigFn!.name}>";
        } else {
            return "<native code>";
        }
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
        throw "Undefined variable '${name}'.";
    }

    void set(String name, IValue? val) {
        if (values.containsKey(name)) {
            values[name] = val;
            return;
        }
        if (parent != null) {
            return parent!.set(name, val);
        }
        throw "Undefined variable '${name}'.";
    }

    void define(String name, IValue? val) {
        if (values.containsKey(name)) {
            throw "Variable '${name}' already exists in this scope";
        }
        values[name] = val;
    }
}


class Interpreter {
    final globals = new Environment();
    late Environment environment;
    late Map<Expr, int> locals;

    Interpreter() {
        this.environment = globals;

        globals.define("millis", new IValue(IType.Function, new JigFunction(
            (Interpreter interpreter, List<Object> arguments) {
                return IValue(IType.Double, DateTime.now().millisecondsSinceEpoch.toDouble());
            },
            new Environment(environment)
        )));

    }

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
                return IValue(IType.String, tok.lexeme.substring(1, tok.lexeme.length - 1));
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

        if (expr is CallExpr) {
            IValue callee = evaluate(expr.callee);

            List<IValue> arguments = [];
            for (Expr argument in expr.orderedArguments) { 
                arguments.add(evaluate(argument));
            }

            final func = callee.value as JigFunction;
            // TODO: check arity
            return func.call(this, arguments);
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
            final varName = expr.nameToken.lexeme;
            int? distance = locals[expr];
            if (distance != null) {
                Environment environment = this.environment;
                for (int i = 0; i < distance; i++) {
                    environment = environment.parent!; 
                }
                return environment.values[varName]!;
            } else {
                final val = globals.get(varName);
                if (val == null) {
                    throw "variable ${varName} must be initialized before use";
                }
                return val;
            }
        }

        if (expr is AssignmentExpr) {
            IValue value = evaluate(expr.expr);
            environment.set(expr.nameToken.lexeme, value);

            final varName = expr.nameToken.lexeme;
            int? distance = locals[expr];
            if (distance != null) {
                Environment environment = this.environment;
                for (int i = 0; i < distance; i++) {
                    environment = environment.parent!; 
                }
                environment.values[varName] = value;
                return value;
            } else {
                globals.set(varName, value);
            }


            return value;
        }

        if (expr is FunctionExpr) {
            JigFunction func = new JigFunction(expr, new Environment(environment));
            return new IValue(IType.Function, func);
        }

        throw "unreachable Expression ${expr.toString()}";
    }

    IValue? executeInNewScope(List<Stmt> statements, Environment environment) {
        Environment previous = this.environment;
        this.environment = environment;

        IValue? res;
        for (final statement in statements) {
            res = executeStatement(statement);
            if (res != null) {
                this.environment = previous;
                return res;
            }
        }
        
        this.environment = previous;
        return null;
    }

    IValue? executeStatement(Stmt stmt){
        if (stmt is ExpressionStmt) {
            if (stmt.expr is FunctionExpr) {
                final expr = stmt.expr as FunctionExpr;
                JigFunction func = new JigFunction(expr, new Environment(environment));
                environment.define(expr.name.lexeme, new IValue(IType.Function, func));
            } else {
                evaluate(stmt.expr);
            }
            return null;
        }

        if (stmt is IfStmt) {
            IValue? res;
            if (isTruthy(evaluate(stmt.condition))) {
                res = executeStatement(stmt.thenBranch);
            } else if (stmt.elseBranch != null) {
                res = executeStatement(stmt.elseBranch!);
            }
            if (res != null) {
                return res;
            }
            return null;
        }

        if (stmt is WhileStmt) {
            IValue? res;
            while (isTruthy(evaluate(stmt.condition))) {
                res = executeStatement(stmt.body);
                if (res != null) {
                    return res;
                }
            }
            return null; 
        }

        if (stmt is BlockStmt) {
            IValue? res = executeInNewScope(stmt.stmts, new Environment(environment));
            if (res != null) {
                return res;
            }
            return null;
        }

        if (stmt is PrintStmt) {
            IValue value = evaluate(stmt.expr);
            print(value.toString());
            return null;
        }

        if (stmt is VariableStmt) {
            IValue? value = null;
            if (stmt.expr != null) {
                value = evaluate(stmt.expr!);
            }
            environment.define(stmt.name.lexeme, value);
            return null;
        }

        if (stmt is ReturnStmt) {
            if (stmt.value != null) {
                return evaluate(stmt.value!);
            } else {
                return IValue(IType.Null, 0);
            }
        }

        return null;
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
                        return IValue(IType.String, (left.value as String) + (right.value as String));
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
        final resolver = new Resolver();
        final (locals, errors) = resolver.resolve(statements);
        this.locals = locals;

        if (errors.isNotEmpty) {
            throw errors;
        }

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