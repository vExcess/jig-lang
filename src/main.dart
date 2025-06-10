import 'dart:io';
import 'interpreter/interpreter.dart';
import 'parser/tokenizer.dart';
import 'parser/parser.dart';
import 'ast-printer.dart';

void main() {
    String src = File("./thing.jig").readAsStringSync();
    
    var tokenizer = Tokenizer(src);
    var tokens = tokenizer.parseAll();
    // tokens.forEach((tok) {
    //     print(tok.toString());
    // });

    var parser = Parser(tokens);
    var ast = parser.parse();

    var astPrinter = ASTPrinter(src);
    astPrinter.printAST(ast);

    var interpreter = Interpreter();
    print("==========");
    interpreter.interpret(ast);
}