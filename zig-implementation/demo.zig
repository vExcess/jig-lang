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


const FS = struct {
    fn cwd() std.fs.Dir {
        return std.fs.cwd();
    }

    fn open(dir: std.fs.Dir, path: []const u8, args: []const u8) !std.fs.File {
        var read = false;
        var write = false;
        var append = false;

        var i: usize = 0;
        while (i < args.len) : (i += 1) {
            switch (args[i]) {
                'r' => {
                    read = true;
                },
                'w' => {
                    write = true;
                },
                'a' => {
                    append = true;
                },
                else => @panic("invalid FS.open argument")
            }
        }

        var argsStruct: std.fs.File.OpenFlags = undefined;

        if (read and (write or append)) {
            argsStruct = .{ .mode = .read_write };
        } else if (read) {
            argsStruct = .{ .mode = .read_only };
        } else {
            argsStruct = .{ .mode = .write_only };
        }

        return dir.openFile(
            path,
            argsStruct,
        );
    }


};

fn freeConstPoolString(pool: *ConstantPool) void {
    var i: u32 = 0;
    while (i < pool.len) : (i += 1) {
        var item = pool.get(i);
        if (item == .STRING) {
            item.STRING.free();
        }
    }
}

pub fn main() !void {
    // setup allocator
    var generalPurposeAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = generalPurposeAllocator.deinit();
    const allocator = generalPurposeAllocator.allocator();
    vexlib.init(&allocator);

    const Map = vexlib.Map([]const u8, f64);
    var map = Map.alloc();
    defer map.dealloc();
    map.set("hello", 123.456);
    println(map.get("hello").?);

    // const sourceFile = try FS.open(FS.cwd(), "./test/dev.trad", "rw");
    // var sourceBuffer = Uint8Array.alloc(As.u32T(try sourceFile.getEndPos()));
    // defer sourceBuffer.dealloc();
    // sourceBuffer.len += As.u32(try sourceFile.read(sourceBuffer.buffer));
    // println(String.using(sourceBuffer));

    // var program = Chunk.alloc(8);
    // defer program.dealloc();

    // var lines = Uint16Array.alloc(0);
    // defer lines.dealloc();

    // var constPool = ConstantPool.alloc(0);
    // defer constPool.dealloc();

    // const Time = vexlib.Time;

    // const start = Time.millis();
    // var compiler = Compiler.init();
    // const success = compiler.compile(
    //     String.using(sourceBuffer),
    //     &program,
    //     &lines,
    //     &constPool
    // );
    // if (success) {
    //     print("Compiler exited successfully");
    //     const outFile = try FS.open(FS.cwd(), "./test/dev.trab", "w");
    //     _= try outFile.write(program.buffer);
    // }

    // println("\n-------- BYTECODE --------");
    // disassembleChunk(&program, &constPool, &lines, "test");

    // println("\n-------- EXEC --------");
    // var vm = VM.alloc(&program, &constPool, &lines);
    // defer vm.dealloc();
    // _=vm.run();

    // // cleanup
    // freeConstPoolString(&constPool);

    // const end = Time.millis();
    // print(end - start);
    // println("ms");
}
