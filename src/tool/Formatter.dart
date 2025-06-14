import '../data/Expr.dart';
import '../data/Stmt.dart';
import '../data/Token.dart';

class Formatter {
    static String formatExpr(Expr expr, [int depth=0]) {
        if (expr is BinaryExpr) {
            return "${formatExpr(expr.left, depth+1)} ${expr.operator.lexeme} ${formatExpr(expr.right, depth+1)}";
        }
        if (expr is LiteralExpr) {
            return "${expr.token.lexeme}";
        }
        if (expr is UnaryExpr) {
            return "${expr.operator.lexeme}${formatExpr(expr.right, depth+1)}";
        }
        if (expr is VariableExpr) {
            return "${expr.nameToken.lexeme}";
        }
        if (expr is AssignmentExpr) {
            return "${formatExpr(expr.left)} = ${formatExpr(expr.right)}";
        }
        if (expr is CallExpr) {
            final callee = formatExpr(expr.callee);
            final args = expr.orderedArguments.map((expr) => formatExpr(expr, depth + 1)).join(", ");
            return "${callee}(${args})";
        }
        if (expr is NewExpr) {
            final callee = formatExpr(expr.callee);
            final args = expr.arguments.map((expr) => formatExpr(expr, depth + 1)).join(", ");
            return "new ${callee}(${args})";
        }
        if (expr is MemberExpr) {
            return "${formatExpr(expr.object)}.${expr.propertyToken.lexeme}";
        }
        if (expr is GroupingExpr) {
            return "(${formatExpr(expr.expression)})";
        }
        if (expr is FunctionExpr) {
            final pad = "    " * (depth + 1);
            final parameters = expr.params.map((token) => token.lexeme).join(", ");
            final bodyStr = "{\n${pad}${expr.body.map((stmt) => formatStmt(stmt, depth + 1)).join("\n${pad}")}\n${pad.substring(4 * (depth))}}";
            return "${expr.kind == FunctionType.FUNCTION ? "fn " : ""}${expr.name.lexeme}(${parameters}) ${bodyStr}";
        }
        throw "Unknown expression type " + expr.toString();
    }

    static String formatStmt(Stmt stmt, [int depth=0]) {
        if (stmt is ExpressionStmt) {
            return formatExpr(stmt.expr);
        }
        if (stmt is PrintStmt) {
            return "print(${formatExpr(stmt.expr)})";
        }
        if (stmt is VariableStmt) {
            return "${stmt.varType} ${stmt.name.lexeme} = ${stmt.expr == null ? "" : formatExpr(stmt.expr!)}";
        }
        if (stmt is BlockStmt) {
            final pad = "    " * (depth + 1);
            return "{\n${pad}${stmt.stmts.map((stmt) => formatStmt(stmt, depth + 1)).join("\n${pad}")}\n${pad.substring(4)}}";
        }
        if (stmt is IfStmt) {
            final pad = "    " * (depth + 1);
            final thenStr = "{\n${pad}${formatStmt(stmt.thenBranch, depth + 1)}\n${pad.substring(4)}}";
            final elseStr = stmt.elseBranch == null ? "" : "else {\n${pad}${formatStmt(stmt.elseBranch!, depth + 1)}\n${pad.substring(4)}}";
            return "if (${formatExpr(stmt.condition)}) ${thenStr} ${elseStr}";
        }
        if (stmt is WhileStmt) {
            final pad = "    " * (depth + 1);
            final bodyStr = "{\n${pad}${formatStmt(stmt.body, depth + 1)}\n${pad.substring(4)}}";
            return "while (${formatExpr(stmt.condition)}) ${bodyStr}";
        }
        if (stmt is ReturnStmt) {
            return "return ${stmt.value == null ? "" : formatExpr(stmt.value!)}";
        }
        if (stmt is ClassStmt) {
            final pad = "    " * (depth + 1);
            final bodyStr = "{\n${pad}${stmt.methods.map((stmt) => formatExpr(stmt, depth + 1)).join("\n${pad}")}\n}";
            return "class ${stmt.name.lexeme} ${bodyStr}";
        }
        throw "UNKNOWN STATEMENT TYPE " + stmt.toString();
    }

    static String formatAST(List<Stmt> statements) {
        return statements.map((stmt) => formatStmt(stmt)).join("\n");
    }
}
