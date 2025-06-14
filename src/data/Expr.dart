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

class ThisExpr extends Expr {
    Token token;
    ThisExpr(this.token);
}

class AssignmentExpr extends Expr {
    Expr left; 
    Expr right;
    AssignmentExpr(this.left, this.right);
}

class CallExpr extends Expr {
    Expr callee;
    List<Expr> orderedArguments;
    Map<String, Expr> unorderedArguments;
    Token paren;
    CallExpr(this.callee, this.orderedArguments, this.unorderedArguments, this.paren);
}

class FunctionExpr extends Expr {
    FunctionType kind;
    bool isPrivate;
    Token name;
    List<Token> params;
    List<Stmt> body;
    FunctionExpr(this.kind, this.name, this.params, this.body, [this.isPrivate=false]);
}

class MemberExpr extends Expr {
    Expr object;
    Token propertyToken;
    MemberExpr(this.object, this.propertyToken);
}

class NewExpr extends Expr {
    Expr callee;
    List<Expr> arguments;
    NewExpr(this.callee, this.arguments);
}

class SuperExpr extends Expr {
    Token token;
    Token parentName;
    SuperExpr(this.token, this.parentName);
}