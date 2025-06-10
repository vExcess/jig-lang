import 'dart:math';

import '../data/Token.dart';
import '../data/Expr.dart';
import '../data/Stmt.dart';
import '../lib/Stack.dart';

enum FunctionType {
    NONE,
    FUNCTION
}

class Resolver {
    // will break if code has more than 64 levels of nesting
    Stack<Map<String, bool>> scopes = new Stack(64);
    FunctionType currentFunction = FunctionType.NONE;

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
                throw "Can't return from top-level code at ${stmt}";
            }

            if (stmt.value != null) {
                resolveExpr(stmt.value!);
            }
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

        if (expr is UnaryExpr) {
            resolveExpr(expr.right);
        }

        if (expr is VariableExpr) {
            resolveLocal(expr, expr.nameToken);
        }

        if (expr is AssignmentExpr) {
            resolveExpr(expr.expr);
            resolveLocal(expr, expr.nameToken);
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