import 'Token.dart';
import 'Stmt.dart';

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

class CallExpr extends Expr {
    Expr callee;
    List<Expr> orderedArguments;
    Map<String, Expr> unorderedArguments;
    Token paren;
    CallExpr(this.callee, this.orderedArguments, this.unorderedArguments, this.paren);
}

class FunctionExpr extends Expr {
    Token name;
    List<Token> params;
    List<Stmt> body;
    FunctionExpr(this.name, this.params, this.body);
}