import 'dart:io';
import 'interpreter/interpreter.dart';
import 'parser/tokenizer.dart';
import 'parser/parser.dart';
import 'tool/Formatter.dart';
import 'tool/Serializer.dart';

void main() {
    String src = File("./thing.jig").readAsStringSync();
    
    var tokenizer = Tokenizer(src);
    var tokens = tokenizer.parseAll();
    // tokens.forEach((tok) {
    //     print(tok.toString());
    // });

    var parser = Parser(tokens);
    var ast = parser.parse();

    print(Serializer.stringFromJSON(Serializer.jsonifyAST(ast)));
    print(Formatter.formatAST(ast));

    var interpreter = Interpreter();
    print("==========");
    interpreter.interpret(ast);
}