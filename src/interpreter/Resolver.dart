/*

    Important: Each new scope created by the resolver needs a new
    environment created for it in the interpreter

*/

import '../data/Token.dart';
import '../data/Expr.dart';
import '../data/Stmt.dart';
import '../lib/Stack.dart';

class Resolver {
    // will break if code has more than 64 levels of nesting
    Stack<Map<String, bool>> scopes = new Stack(64);

    FunctionType currentFunction = FunctionType.NONE;
    ClassType currentClass = ClassType.NONE;

    late Map<Expr, int> locals;
    late List<String> errors;

    void error(String err) {
        this.errors.add(err);
    }

    void beginScope() {
        scopes.push(new Map<String, bool>());
    }

    void endScope() {
        scopes.pop();
    }

    void declare(Token name) {
        if (scopes.isEmpty()) return;
        Map<String, bool> scope = scopes.peek();
        if (scope.containsKey(name.lexeme)) {
            throw "Use #shadowable if you intend to shadow ${name}.";
        }
        scope[name.lexeme] = false;
    }

    void define(Token name) {
        if (scopes.isEmpty()) return;
        scopes.peek()[name.lexeme] = true;
    }

    (Map<Expr, int>, List<String>) resolve(List<Stmt> root) {
        this.locals = {};
        this.errors = [];
        resolveStmts(root);
        return (locals, errors);
    }

    void resolveStmts(List<Stmt> statements) {
        for (final statement in statements) {
            resolveStmt(statement);
        }
    }

    void resolveStmt(Stmt stmt) {
        if (stmt is ExpressionStmt) {
            final expr = stmt.expr;
            if (expr is FunctionExpr) {
                declare(expr.name);
                define(expr.name);

                resolveFunction(expr, FunctionType.FUNCTION);
            } else {
                resolveExpr(expr);
            }
        }

        if (stmt is IfStmt) {
            resolveExpr(stmt.condition);
            resolveStmt(stmt.thenBranch);
            if (stmt.elseBranch != null) resolveStmt(stmt.elseBranch!);
        }

        if (stmt is WhileStmt) {
            resolveExpr(stmt.condition);
            resolveStmt(stmt.body);
        }

        if (stmt is BlockStmt) {
            beginScope();
            resolveStmts(stmt.stmts);
            endScope();
        }

        if (stmt is PrintStmt) {
            resolveExpr(stmt.expr);
        }

        if (stmt is VariableStmt) {
            declare(stmt.name);
            if (stmt.expr != null) {
                resolveExpr(stmt.expr!);
            }
            define(stmt.name);
        }

        if (stmt is ReturnStmt) {
            if (currentFunction == FunctionType.NONE) {
                error("Can't return from top-level code at ${stmt}");
            } else if (currentFunction == FunctionType.INITIALIZER && stmt.value != null) {
                error("Can't return a value from an initializer ${stmt}");
            }

            if (stmt.value != null) {
                resolveExpr(stmt.value!);
            }
        }

        if (stmt is ClassStmt) {
            declare(stmt.name);
            define(stmt.name);

            for (VariableExpr parent in stmt.parents) {
                if (parent.nameToken.lexeme == stmt.name.lexeme) {
                    error("A class can't inherit from itself");
                }
                resolveExpr(parent);
            }

            beginScope();
            scopes.peek()["this"] = true;
            if (stmt.parents.isNotEmpty) {
                scopes.peek()["super"] = true;
            }

            for (FunctionExpr method in stmt.methods) {
                final declaration = method.name.lexeme == "new" ? FunctionType.INITIALIZER : FunctionType.METHOD;

                // set in "class" environment for methods that have a this parameter
                ClassType enclosingClass = currentClass;
                if (method.params[0].lexeme == "this") {
                    currentClass = ClassType.CLASS;
                }
                resolveFunction(method, declaration);
                currentClass = enclosingClass;
            }

            endScope();
        }
    }

    void resolveExpr(Expr expr) {
        if (expr is LiteralExpr) {
            return;
        }

        if (expr is BinaryExpr) {
            resolveExpr(expr.left);
            resolveExpr(expr.right);
        }

        if (expr is GroupingExpr) {
            resolveExpr(expr.expression);
        }

        if (expr is CallExpr) {
            resolveExpr(expr.callee);
            for (Expr argument in expr.orderedArguments) {
                resolveExpr(argument);
            }
        }

        if (expr is NewExpr) {
            resolveExpr(expr.callee);
            for (Expr argument in expr.arguments) {
                resolveExpr(argument);
            }
        }

        if (expr is SuperExpr) {
            resolveLocal(expr, expr.parentName);
        }

        if (expr is MemberExpr) {
            resolveExpr(expr.object);
        }

        if (expr is UnaryExpr) {
            resolveExpr(expr.right);
        }

        if (expr is VariableExpr) {
            if (currentClass == ClassType.NONE && expr.nameToken.lexeme == "this") {
                error("Can't use 'this' outside of class methods ${expr.nameToken}");
                return;
            }
            resolveLocal(expr, expr.nameToken);
        }

        if (expr is AssignmentExpr) {
            resolveExpr(expr.right);
            final left = expr.left;
            if (left is VariableExpr) {
                resolveLocal(expr, left.nameToken);
            } else {
                resolveExpr(left);
            }
        }

        if (expr is FunctionExpr) {
            resolveFunction(expr, FunctionType.FUNCTION);
        }
    }

    void resolveFunction(FunctionExpr function, FunctionType funcType) {
        FunctionType enclosingFunction = currentFunction;
        currentFunction = funcType;

        beginScope();
        for (Token param in function.params) {
            declare(param);
            define(param);
        }
        resolveStmts(function.body);
        endScope();

        currentFunction = enclosingFunction;
    }

    void resolveLocal(Expr expr, Token name) {
        for (int i = scopes.size() - 1; i >= 0; i--) {
            if (scopes.peek(i).containsKey(name.lexeme)) {
                locals[expr] = scopes.size() - 1 - i;
                return;
            }
        }
    }

}