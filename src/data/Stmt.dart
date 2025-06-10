import 'Token.dart';
import 'Expr.dart';

enum StmtType {
    EXPRESSION,
    PRINT
}

class Stmt {}

class ExpressionStmt extends Stmt {
    Expr expr;
    ExpressionStmt(this.expr);
}

class BlockStmt extends Stmt {
    List<Stmt> stmts;
    BlockStmt(this.stmts);
}

class PrintStmt extends Stmt {
    Expr expr;
    PrintStmt(this.expr);
}

class VariableStmt extends Stmt {
    TokenType varType;
    Token name;
    Expr? expr;
    VariableStmt(this.varType, this.name, this.expr);
}

class IfStmt extends Stmt {
    Expr condition;
    Stmt thenBranch;
    Stmt? elseBranch;
    IfStmt(this.condition, this.thenBranch, this.elseBranch);
}

class WhileStmt extends Stmt {
    Expr condition;
    Stmt body;
    WhileStmt(this.condition, this.body);
}

class ReturnStmt extends Stmt {
    Expr? value;
    Token token;
    ReturnStmt(this.value, this.token);
}