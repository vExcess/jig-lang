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
    Int,
    Double,
    Null,
    Object,
    String,
    Function,
    Class
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

class JigObject {
    JigClass jClass;
    Map<String, IValue> fields = {};

    JigObject(this.jClass);

    IValue get(String key) {
        if (fields.containsKey(key)) {
            return fields[key]!;
        }

        JigFunction? methodLookup = jClass.getMethod(key);
        if (methodLookup != null) {
            return new IValue(IType.Function, methodLookup);
        }

        throw "Undefined property '${key}'.";
    }

    void set(String name, IValue value) {
        fields[name] = value;
    }

    String toString() {
        return "Instance of ${jClass}";
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

    IValue call(Interpreter interpreter, List<IValue> arguments, [bool isConstructor=false]) {
        if (jigFn != null) {
            Environment environment = new Environment(closure);
            
            for (int i = 0; i < jigFn!.params.length; i++) {
                environment.define(
                    jigFn!.params[i].lexeme,
                    arguments[i]
                );
            }

            IValue? res = interpreter.executeInNewScope(jigFn!.body, environment);
            
            // return "this" in constructors
            if (isConstructor) {
                return environment.values["this"]!;
            }

            // return returned value in functions
            if (res != null) {
                return res;
            }

            // return null otherwise
            return new IValue(IType.Null, 0);
        } else {
            return nativeFn!(interpreter, arguments);
        }
    }

    String toString() {
        if (jigFn != null) {
            return "<fn ${jigFn!.name.lexeme}(${jigFn!.params.map((tok) { return tok.lexeme; }).join(", ")})>";
        } else {
            return "<fn native code>";
        }
    }
}

class JigClass {
    String name;
    List<JigClass> parents;
    Map<String, JigFunction> methods;

    JigClass(this.name, this.parents, this.methods);
    
    JigFunction? getMethod(String key) {
        if (methods.containsKey(key)) {
            return methods[key]!;
        }

        for (JigClass parent in parents) {
            final parentMethodLookup = parent.getMethod(key);
            if (parentMethodLookup != null) {
                return parentMethodLookup;
            }
        }

        return null;
    }

    String toString() {
        return "<class ${name}>";
    }
}

JigClass ObjectClass = new JigClass("Object", [], {});

class Environment {
    Environment? parent = null;
    Map<String, IValue?> values = {};

    Environment([this.parent]);

    Environment getNthParent(int dist) {
        Environment environment = this;
        for (int i = 0; i < dist; i++) {
            environment = environment.parent!; 
        }
        return environment;
    }

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

    bool _debugMode = true;
    List<String> _debugStack = [];
    void debugPush(String exprType) {
        if (_debugMode) {
            _debugStack.add(exprType);
            print(_debugStack);
        }
    }
    void debugPop() {
        if (_debugMode) _debugStack.removeLast();
    }

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
            debugPush("LiteralExpr");
            final tok = expr.token;
            if (tok.tokType == TokenType.NULL) {
                final output = IValue(IType.Null, 0);
                debugPop();
                return output;
            }
            if (tok.tokType == TokenType.NUMBER) {
                final output = IValue(IType.Double, double.parse(tok.lexeme));
                debugPop();
                return output;
            }
            if (tok.tokType == TokenType.STRING) {
                final output = IValue(IType.String, tok.lexeme.substring(1, tok.lexeme.length - 1));
                debugPop();
                return output;
            }
            if (tok.lexeme == "true") {
                final output = IValue(IType.Bool, true);
                debugPop();
                return output;
            }
            if (tok.lexeme == "false") {
                final output = IValue(IType.Bool, false);
                debugPop();
                return output;
            }
            throw "UNREACHABLE - unknown literal";
        }

        if (expr is BinaryExpr) {
            debugPush("BinaryExpr");
            final output = visitBinaryExpr(expr);
            debugPop();
            return output;
        }

        if (expr is GroupingExpr) {
            debugPush("GroupingExpr");
            final output = evaluate(expr.expression);
            debugPop();
            return output;
        }

        if (expr is CallExpr) {
            debugPush("CallExpr");
            IValue callee = evaluate(expr.callee);
            final func = callee.value as JigFunction;

            List<IValue> arguments = [];
            
            // handle this for method calls
            final jigFn = func.jigFn;
            if (jigFn != null && jigFn.params.isNotEmpty && jigFn.params[0].lexeme == "this" && expr.callee is MemberExpr) {
                final calleeExpr = expr.callee as MemberExpr;
                IValue thisObject = evaluate(calleeExpr.object);
                arguments.add(thisObject);
            }
            
            for (Expr argument in expr.orderedArguments) { 
                arguments.add(evaluate(argument));
            }

            // TODO: check arity
            debugPop();
            return func.call(this, arguments);
        }

        if (expr is NewExpr) {
            debugPush("NewExpr");
            IValue callee = evaluate(expr.callee);
            print("EAVAL CALLEEE");
            
            if (callee.type == IType.Class) {
                final classToNew = callee.value as JigClass;
                final newObject = new IValue(IType.Object, new JigObject(classToNew));

                List<IValue> arguments = [newObject];
                for (Expr argument in expr.arguments) {
                    arguments.add(evaluate(argument));
                }

                JigFunction? func = classToNew.getMethod("new");
                // TODO: check arity
                debugPop();
                return func!.call(this, arguments, true);
            }

            throw "Only classes can be instantiated";
        }

        if (expr is MemberExpr) {
            debugPush("MemberExpr");
            IValue object = evaluate(expr.object);
            if (object.type == IType.Object) {
                debugPop();
                return (object.value as JigObject).get(expr.propertyToken.lexeme);
            } else if (object.type == IType.Class) {
                // resolve static methods
                final jClass = (object.value as JigClass);
                final methodLookup = jClass.getMethod(expr.propertyToken.lexeme);
                if (methodLookup == null) {
                    throw "unable to resolve method ${expr.propertyToken.lexeme} on ${jClass.name}";
                }
                debugPop();
                return new IValue(IType.Function, methodLookup);
            }
            throw "Only objects have properties ${expr}.";
        }

        if (expr is UnaryExpr) {
            debugPush("UnaryExpr");
            IValue right = evaluate(expr.right);

            switch (expr.operator.tokType) {
                case TokenType.BANG:
                    debugPop();
                    return IValue(right.type, !isTruthy(right));
                case TokenType.MINUS:
                    checkNumberOperand(expr.operator, right);
                    debugPop();
                    return IValue(right.type, -(right.value as double));
                default:

            }

            throw "unreachable UnaryExpr";
        }

        if (expr is VariableExpr) {
            debugPush("VariableExpr");
            final varName = expr.nameToken.lexeme;
            int? distance = locals[expr];
            if (distance != null) {
                Environment environment = this.environment.getNthParent(distance);
                debugPop();
                return environment.get(varName)!;
            } else {
                final val = globals.get(varName);
                if (val == null) {
                    throw "variable ${varName} must be initialized before use";
                }
                debugPop();
                return val;
            }
        }

        if (expr is AssignmentExpr) {
            debugPush("AssignmentExpr");
            final left = expr.left;
            final right = expr.right;

            IValue value = evaluate(expr.right);

            if (left is VariableExpr) {
                final varName = left.nameToken.lexeme;
                int? distance = locals[expr];
                if (distance != null) {
                    Environment environment = this.environment.getNthParent(distance);
                    environment.values[varName] = value;
                } else {
                    globals.set(varName, value);
                }
            } else if (left is MemberExpr) {
                IValue object = evaluate(left.object);
                if (object.type != IType.Object) {
                    // TODO: implement class modifying
                    throw "Only instances have fields. ${expr}";
                }
                (object.value as JigObject).set(left.propertyToken.lexeme, value);
            }

            debugPop();
            return value;
        }

        if (expr is SuperExpr) {
            debugPush("SuperExpr");
            int distance = locals[expr]!;
            Environment environment = this.environment.getNthParent(distance);
            final superObject = environment.get("super")!.value as JigObject;
            final superClass = superObject.fields[expr.parentName.lexeme];
            if (superClass == null) {
                throw "unreachable (probably)";
            }
            debugPop();
            return superClass;
        }

        if (expr is FunctionExpr) {
            debugPush("FunctionExpr");
            JigFunction func = new JigFunction(expr, new Environment(environment));
            debugPop();
            return new IValue(IType.Function, func);
        }

        throw "UNREACHABLE - unknown expression ${expr}";
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

    IValue? executeStatement(Stmt stmt) {
        if (stmt is ExpressionStmt) {
            debugPush("ExpressionStmt");
            if (stmt.expr is FunctionExpr) {
                final expr = stmt.expr as FunctionExpr;
                JigFunction func = new JigFunction(expr, new Environment(environment));
                environment.define(expr.name.lexeme, new IValue(IType.Function, func));
            } else {
                evaluate(stmt.expr);
            }
            debugPop();
            return null;
        }

        if (stmt is IfStmt) {
            debugPush("IfStmt");
            IValue? res;
            if (isTruthy(evaluate(stmt.condition))) {
                res = executeStatement(stmt.thenBranch);
            } else if (stmt.elseBranch != null) {
                res = executeStatement(stmt.elseBranch!);
            }
            if (res != null) {
                debugPop();
                return res;
            }
            debugPop();
            return null;
        }

        if (stmt is WhileStmt) {
            debugPush("WhileStmt");
            IValue? res;
            while (isTruthy(evaluate(stmt.condition))) {
                res = executeStatement(stmt.body);
                if (res != null) {
                    debugPop();
                    return res;
                }
            }
            debugPop();
            return null; 
        }

        if (stmt is BlockStmt) {
            debugPush("BlockStmt");
            IValue? res = executeInNewScope(stmt.stmts, new Environment(environment));
            if (res != null) {
                debugPop();
                return res;
            }
            debugPop();
            return null;
        }

        if (stmt is PrintStmt) {
            debugPush("PrintStmt");
            IValue value = evaluate(stmt.expr);
            print(value.toString());
            debugPop();
            return null;
        }

        if (stmt is VariableStmt) {
            debugPush("VariableStmt");
            IValue? value = null;
            if (stmt.expr != null) {
                value = evaluate(stmt.expr!);
            }
            environment.define(stmt.name.lexeme, value);
            debugPop();
            return null;
        }

        if (stmt is ReturnStmt) {
            debugPush("ReturnStmt");
            if (stmt.value != null) {
                debugPop();
                return evaluate(stmt.value!);
            } else {
                debugPop();
                return IValue(IType.Null, 0);
            }
        }

        if (stmt is ClassStmt) {
            debugPush("ClassStmt");
            List<JigClass> parentClasses = [];
            for (VariableExpr parent in stmt.parents) {
                IValue parentClass = evaluate(parent);
                if (parentClass.type != IType.Class) {
                    throw "Superclass must be a class. ${parent.nameToken}";
                }
                parentClasses.add(parentClass.value as JigClass);
            }

            final jClassName = stmt.name.lexeme;
            environment.define(jClassName, null);

            // define super 
            if (stmt.parents.isNotEmpty) {
                final superObject = new JigObject(ObjectClass);
                for (final parentClass in parentClasses) {
                    superObject.fields[parentClass.name] = new IValue(IType.Class, parentClass);
                }
                environment.define("super", new IValue(IType.Object, superObject));
            }

            Map<String, JigFunction> methods = {};
            for (FunctionExpr expr in stmt.methods) {
                methods[expr.name.lexeme] = new JigFunction(expr, environment);
            }

            final jClass = new JigClass(jClassName, parentClasses, methods);
            environment.set(jClassName, new IValue(IType.Class, jClass));

            debugPop();
            return null;
        } 

        throw "UNREACHABLE - unknown statement ${stmt}";
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