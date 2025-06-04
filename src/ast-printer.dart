import 'parser.dart';

class ASTPrinter {
    String src;

    ASTPrinter(this.src);

    String stringifyExpr(Expr expr, [int depth=0]) {
        if (expr is BinaryExpr) {
            return "(${stringifyExpr(expr.left, depth+1)} ${expr.operator.lexeme} ${stringifyExpr(expr.right, depth+1)})";
        }
        if (expr is LiteralExpr) {
            return "${expr.token.lexeme}";
        }
        if (expr is UnaryExpr) {
            return "${expr.operator.lexeme}${stringifyExpr(expr.right, depth+1)}";
        }
        if (expr is VariableExpr) {
            return "${expr.nameToken.lexeme}";
        }
        if (expr is AssignmentExpr) {
            return "${expr.nameToken.lexeme} = ${stringifyExpr(expr.expr)}";
        }
        throw "Unknown expression type " + expr.toString();
    }

    String mapifyExpr(Expr expr, [int depth=0]) {
        final pad = "    " * depth;
        if (expr is BinaryExpr) {
            return """{${depth == 0 ? pad : pad.substring(4 * depth)}L: ${mapifyExpr(expr.left, depth+1)},
${pad} O: ${expr.operator.toString(true)},
${pad} R: ${mapifyExpr(expr.right, depth+1)}}""";
        }
        if (expr is LiteralExpr) {
            return expr.token.toString(true);
        }
        if (expr is UnaryExpr) {
            return "Unary[${expr.operator.toString(true)}, ${mapifyExpr(expr.right, depth+1)}]";
        }
        throw "Unknown expression type " + expr.toString();
    }

    String stringifyStmt(Stmt stmt, [int depth=0]) {
        if (stmt is ExpressionStmt) {
            return stringifyExpr(stmt.expr);
        }
        if (stmt is PrintStmt) {
            return "print(${stringifyExpr(stmt.expr)})";
        }
        if (stmt is VariableStmt) {
            return "${stmt.varType} ${stmt.name} = ${stmt.expr == null ? "undefined" : stringifyExpr(stmt.expr!)}";
        }
        if (stmt is BlockStmt) {
            final pad = "    " * (depth + 1);
            return "BLOCK{\n${pad}${stmt.stmts.map((stmt) { return stringifyStmt(stmt, depth + 1);}).join("\n${pad}")}\n${pad.substring(4)}}";
        }
        if (stmt is IfStmt) {
            final pad = "    " * (depth + 1);
            final thenStr = "{\n${pad}${stringifyStmt(stmt.thenBranch, depth + 1)}\n${pad.substring(4)}}";
            final elseStr = stmt.elseBranch == null ? "" : "else {\n${pad}${stringifyStmt(stmt.elseBranch!, depth + 1)}\n${pad.substring(4)}}";
            return "IF (${stringifyExpr(stmt.condition)}) ${thenStr} ${elseStr}";
        }
        if (stmt is WhileStmt) {
            final pad = "    " * (depth + 1);
            final bodyStr = "{\n${pad}${stringifyStmt(stmt.body, depth + 1)}\n${pad.substring(4)}}";
            return "WHILE (${stringifyExpr(stmt.condition)}) ${bodyStr}";
        }
        throw "Unknown statement type " + stmt.toString();
    }

    void printAST(List<Stmt> statements) {
        for (final stmt in statements) {
            // print(stringifyExpr(expr));
            print(stringifyStmt(stmt));
        }
    }

}
