import 'dart:convert';

import '../data/Expr.dart';
import '../data/Stmt.dart';

class Serializer {
    static Map<String, Object> jsonifyStmt(Stmt stmt, [int depth=0]) {
        if (stmt is ExpressionStmt) {
            return {
                "type": "ExpressionStmt",
                "expr": jsonifyExpr(stmt.expr),
            };
        }
        if (stmt is PrintStmt) {
            return {
                "type": "PrintStmt",
                "expr": jsonifyExpr(stmt.expr),
            };
        }
        if (stmt is VariableStmt) {
            return {
                "type": "VariableStmt",
                "varType": stmt.varType.toString(),
                "name": stmt.name.lexeme,
                "expr": stmt.expr == null ? {} : jsonifyExpr(stmt.expr!)
            };
        }
        if (stmt is BlockStmt) {
            return {
                "type": "BlockStmt",
                "stmts": stmt.stmts.map((stmt) => jsonifyStmt(stmt, depth + 1)).toList()
            };
        }
        if (stmt is IfStmt) {
            return {
                "type": "IfStmt",
                "condition": jsonifyExpr(stmt.condition),
                "thenBranch": jsonifyStmt(stmt.thenBranch),
                "elseBranch": stmt.elseBranch == null ? {} : jsonifyStmt(stmt.elseBranch!),
            };
        }
        if (stmt is WhileStmt) {
            return {
                "type": "WhileStmt",
                "condition": jsonifyExpr(stmt.condition),
                "body": jsonifyStmt(stmt.body),
            };
        }
        if (stmt is ReturnStmt) {
            return {
                "type": "ReturnStmt",
                "value": stmt.value == null ? {} : jsonifyExpr(stmt.value!),
            };
        }
        if (stmt is ClassStmt) {
            return {
                "type": "ClassStmt",
                "name": stmt.name.lexeme,
                "parents": stmt.parents.map((expr) => jsonifyExpr(expr)).toList(),
                "methods": stmt.methods.map((stmt) => jsonifyExpr(stmt)).toList(),
            };
        }
        throw "UNKNOWN STATEMENT TYPE " + stmt.toString();
    }

    static Map<String, Object> jsonifyExpr(Expr expr) {
        if (expr is BinaryExpr) {
            return {
                "type": "BinaryExpr",
                "left": jsonifyExpr(expr.left),
                "operator": expr.operator.lexeme,
                "right": jsonifyExpr(expr.right)
            };
        }
        if (expr is LiteralExpr) {
            return {
                "type": "LiteralExpr",
                "token": expr.token.lexeme
            };
        }
        if (expr is UnaryExpr) {
            return {
                "type": "UnaryExpr",
                "operator": expr.operator.lexeme,
                "right": jsonifyExpr(expr.right)
            };
        }
        if (expr is VariableExpr) {
            return {
                "type": "VariableExpr",
                "nameToken": expr.nameToken.lexeme
            };
        }
        if (expr is AssignmentExpr) {
            return {
                "type": "AssignmentExpr",
                "left": jsonifyExpr(expr.left),
                "right": jsonifyExpr(expr.right)
            };
        }
        if (expr is CallExpr) {
            return {
                "type": "CallExpr",
                "callee": jsonifyExpr(expr.callee),
                "orderedArguments": expr.orderedArguments.map((expr) => jsonifyExpr(expr)).toList()
            };
        }
        if (expr is NewExpr) {
            return {
                "type": "NewExpr",
                "callee": jsonifyExpr(expr.callee),
                "arguments": expr.arguments.map((expr) => jsonifyExpr(expr)).toList()
            };
        }
        if (expr is MemberExpr) {
            return {
                "type": "MemberExpr",
                "object": jsonifyExpr(expr.object),
                "propertyToken": expr.propertyToken.lexeme
            };
        }
        if (expr is GroupingExpr) {
            return {
                "type": "GroupingExpr",
                "expression": jsonifyExpr(expr.expression),
            };
        }
        if (expr is FunctionExpr) {
            return {
                "type": "FunctionExpr",
                "kind": expr.kind.toString(),
                "isPrivate": expr.isPrivate,
                "name": expr.name.lexeme,
                "params": expr.params.map((tok) => tok.lexeme).toList(),
                "body": expr.body.map((stmt) => jsonifyStmt(stmt)).toList(),
            };
        }
        throw "Unknown expression type " + expr.toString();
    }

    static List<Map<String, Object>> jsonifyAST(List<Stmt> statements) {
        return statements.map((stmt) => jsonifyStmt(stmt)).toList();
    }

    static String stringFromJSON(Object data) {
        return json.encode(data);
    }
}