const std = @import("std");

const vexlib = @import("./lib/vexlib.zig");
const print = vexlib.print;
const println = vexlib.println;
const String = vexlib.String;
const Array = vexlib.Array;
const Uint8Array = vexlib.Uint8Array;
const Uint16Array = vexlib.Uint16Array;
const As = vexlib.As;
const Int = vexlib.Int;
const Float = vexlib.Float;

const utils = @import("./trad/utils.zig");
const Chunk = utils.Chunk;
const ConstantPool = utils.ConstantPool;
const disassembleChunk = utils.disassembleChunk;

const Compiler = @import("./trad/compiler.zig").Compiler;

const VM = @import("./trad/vm.zig").VM;

pub fn main() !void {
    // setup allocator
    var generalPurposeAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = generalPurposeAllocator.deinit();
    const allocator = generalPurposeAllocator.allocator();
    vexlib.init(&allocator);

    var source = String.allocFrom("\"Hello\" + \" \" + \"World!\"");
    defer source.dealloc();
    println(source);

    var program = Chunk.alloc(8);
    defer program.dealloc();

    var lines = Uint16Array.alloc(0);
    defer lines.dealloc();

    var constPool = ConstantPool.alloc(0);
    defer constPool.dealloc();

    var compiler = Compiler.init();
    const success = compiler.compile(
        source,
        &program,
        &lines,
        &constPool
    );
    if (success) {
        println("Compiler exited successfully");
    }

    println("\n-------- BYTECODE --------");
    disassembleChunk(&program, &constPool, &lines, "test");

    println("\n-------- EXEC --------");
    var vm = VM.alloc(&program, &constPool, &lines);
    defer vm.dealloc();
    _=vm.run();

}
