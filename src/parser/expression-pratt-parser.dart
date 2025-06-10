import '../lib/Stack.dart';
import '../data/Token.dart';

class Precedence {
    static int NONE = 0;
    static int TERM = 1;
    static int FACTOR = 2;
    static int GROUP = 3;
}

class ParserState {
    late Stack stack;
    late Token prevTok;
    late Token currTok;
    late List<Token> tokens;
    int currTokIdx = 0;

    ParserState(List<Token> tokens) {
        this.stack = new Stack(1000);
        this.tokens = tokens;
        this.currTok = tokens[0];
    }

    void advance() {
        prevTok = currTok;
        currTokIdx++;
        if (currTokIdx < tokens.length) {
            currTok = tokens[currTokIdx];
        } else {
            // currTok = null;
        }
    }
}

typedef ParseFn = void Function(ParserState);

class PrecedenceRule {
    late TokenType tokType;
    ParseFn? prefixFn;
    ParseFn? infixFn;
    late int precedence;

    PrecedenceRule(TokenType tokType, ParseFn? prefixFn, ParseFn? infixFn, int precedence) {
        this.tokType = tokType;
        this.prefixFn = prefixFn;
        this.infixFn = infixFn;
        this.precedence = precedence;
    }

    String toString() {
        return "PrecedenceRule{\n" +
            "  ${tokType},\n" + 
            "  ${prefixFn},\n" + 
            "  ${infixFn},\n" + 
            "  ${precedence},\n" + 
        "}";
    }
}

class ExpressionParser {
    static List<PrecedenceRule> precedenceRules = [
        PrecedenceRule(TokenType.PAREN_LEFT, rule_HandleGrouping, null, Precedence.GROUP),
        PrecedenceRule(TokenType.PAREN_RIGHT, null, null, Precedence.GROUP),
        PrecedenceRule(TokenType.PLUS, null, rule_HandleBinary, Precedence.TERM),
        PrecedenceRule(TokenType.MINUS, rule_HandleUnary, rule_HandleBinary, Precedence.TERM),
        PrecedenceRule(TokenType.ASTERISK, null, rule_HandleBinary, Precedence.FACTOR),
        PrecedenceRule(TokenType.SLASH, null, rule_HandleBinary, Precedence.FACTOR),
        PrecedenceRule(TokenType.NUMBER, rule_HandleNumber, null, Precedence.NONE),
    ];

    static PrecedenceRule? getRule(TokenType tokType) {
        for (final rule in ExpressionParser.precedenceRules) {
            if (rule.tokType == tokType) {
                return rule;
            }
        }
        return null;
    }

    static void rule_HandleNumber(ParserState state){
        String value = state.prevTok.lexeme;
        state.stack.push(value);
    }
    static void rule_HandleUnary(ParserState state){
        String operator = state.prevTok.lexeme;
        if (operator[0] == '-') {
            // merge unary subtraction operator into a negative number
            state.currTok.lexeme = "-" + state.currTok.lexeme;
            PrecedenceRule rule = getRule(state.prevTok.tokType)!;
            parsePrecedence(state, rule.precedence + 1);
        }
    }
    static void rule_HandleBinary(ParserState state){
        String operator = state.prevTok.lexeme;
        PrecedenceRule rule = getRule(state.prevTok.tokType)!;
        parsePrecedence(state, rule.precedence + 1);
        state.stack.push(operator);
    }
    static void rule_HandleGrouping(ParserState state){
        parsePrecedence(state, Precedence.NONE);
        state.advance(); // consume closing parenthesis
    }


    static void parsePrecedence(ParserState state, int precedence) {
        state.advance();
        ParseFn? prefixRule = getRule(state.prevTok.tokType)!.prefixFn;
        if (prefixRule == null) {
            throw "Invalid prefix rule";
        }
        prefixRule.call(state);
        
        while (state.currTok.tokType != TokenType.PAREN_RIGHT && precedence <= getRule(state.currTok.tokType)!.precedence) {
            state.advance();
            ParseFn? infixRule = getRule(state.prevTok.tokType)!.infixFn;
            if (infixRule == null) {
                throw "Invalid infix rule";
            }
            infixRule.call(state);
        }
    }

    Stack parse(List<Token> tokens) {
        ParserState state = new ParserState(tokens);
        parsePrecedence(state, Precedence.NONE);
        return state.stack;
    }
}
