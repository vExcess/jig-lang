const vexlib = @import("../lib/vexlib.zig");
const print = vexlib.print;
const println = vexlib.println;
const Array = vexlib.Array;
const String = vexlib.String;
const Uint8Array = vexlib.Uint8Array;
const Uint16Array = vexlib.Uint16Array;
const Int = vexlib.Int;
const Float = vexlib.Float;

pub const OpCode = enum(u8) {
    RETURN,
    CONST,
    NEG,
    ADD,
    SUB,
    MUL,
    DIV,
    NULL,
    TRUE,
    FALSE,
    NOT,
    EQ,
    NEQ,
    GT,
    LT,
    GTE,
    LTE
};

pub const Chunk = Uint8Array;

const ValueType = enum {
    F32,
    BOOL,
    NULL,
    STRING
};
pub const Value = union(ValueType) {
    F32: f32,
    BOOL: bool,
    NULL: usize,
    STRING: *String
};

pub const ConstantPool = Array(Value);

pub fn printValue(value: Value, isLog: bool) void {
    if (isLog) {
        print(">>> ");
    }
    switch (value) {
        .F32 => |val| {
            println(val);
        },
        .BOOL => |val| {
            println(val);
        },
        .NULL => {
            println("null");
        },
        .STRING => |val| {
            println(val.*);
        }
    }
}

pub fn disassembleInstruction(chunk_: *Chunk, pool_: *ConstantPool, lines_: *Uint16Array, offset: u32) u32 {
    var chunk = chunk_;
    var pool = pool_;
    var lines = lines_;

    var offsetStr = Int.toString(offset, 10);
    defer offsetStr.dealloc();
    offsetStr.padStart(4, "0");
    print(offsetStr);
    print("  ");
    
    var lineStr = Int.toString(lines.get(offset), 10);
    defer lineStr.dealloc();
    lineStr.padStart(4, "0");
    print(lineStr);
    print("  ");

    const instruction = chunk.get(offset);
    switch (@as(OpCode, @enumFromInt(instruction))) {
        .RETURN => {
            println("RETURN");
            return offset + 1;
        },
        .CONST => {
            print("CONST ");
            const poolIdx = chunk.get(offset + 1);
            print(poolIdx);
            print("  ");
            printValue(pool.get(poolIdx), false);
            return offset + 2;
        },
        .NEG => {
            println("NEG");
            return offset + 1;
        },
        .ADD => {
            println("ADD");
            return offset + 1;
        },
        .SUB => {
            println("SUB");
            return offset + 1;
        },
        .MUL => {
            println("MUL");
            return offset + 1;
        },
        .DIV => {
            println("DIV");
            return offset + 1;
        },
        .NULL => {
            println("NULL");
            return offset + 1;
        },
        .TRUE => {
            println("TRUE");
            return offset + 1;
        },
        .FALSE => {
            println("FALSE");
            return offset + 1;
        },
        .NOT => {
            println("NOT");
            return offset + 1;
        },
        .EQ => {
            println("EQ");
            return offset + 1;
        },
        .NEQ => {
            println("NEQ");
            return offset + 1;
        },
        .GT => {
            println("GT");
            return offset + 1;
        },
        .LT => {
            println("LT");
            return offset + 1;
        },
        .GTE => {
            println("GTE");
            return offset + 1;
        },
        .LTE => {
            println("LTE");
            return offset + 1;
        },
        // else => {
        //     print("Unknown opcode");
        //     println(instruction);
        //     return offset + 1;
        // }
    }
}

pub fn disassembleChunk(chunk: *Chunk, pool: *ConstantPool, lines: *Uint16Array, name: []const u8) void {
    print("== ");
    print(name);
    println(" ==");

    var offset: u32 = 0;
    while (offset < chunk.len) {
        offset = disassembleInstruction(chunk, pool, lines, offset);
    }
}
