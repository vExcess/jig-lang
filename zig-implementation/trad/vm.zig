const vexlib = @import("../lib/vexlib.zig");
const print = vexlib.print;
const println = vexlib.println;
const Array = vexlib.Array;
const Uint16Array = vexlib.Uint16Array;
const String = vexlib.String;

const utils = @import("./utils.zig");
const Chunk = utils.Chunk;
const OpCode = utils.OpCode;
const ConstantPool = utils.ConstantPool;
const Value = utils.Value;
const printValue = utils.printValue;
const disassembleInstruction = utils.disassembleInstruction;

const InterpretResult = enum {
    OK,
    COMPILE_ERR,
    RUNTIME_ERR
};

pub const VM = struct {
    chunk: *Chunk,
    constPool: *ConstantPool,
    lines: *Uint16Array,
    stack: Array(Value),
    strings: Array(*String),
    stackPtr: u32,

    pub fn alloc(chunk: *Chunk, pool: *ConstantPool, lines: *Uint16Array) VM {
        return VM{
            .chunk = chunk,
            .constPool = pool,
            .lines = lines,
            .stack = Array(Value).alloc(256),
            .strings = Array(*String).alloc(4),
            .stackPtr = 0
        };
    }

    pub fn dealloc(self: *VM) void {
        var i: u32 = 0;
        while (i < self.strings.len) : (i += 1) {
            var item = self.strings.get(i);
            item.free();
        }
        self.strings.dealloc();
        self.stack.dealloc();
    }

    fn pop(self: *VM) Value {
        self.stackPtr -= 1;
        return self.stack.get(self.stackPtr);
    }

    fn peek(self: *VM, dist: u32) Value {
        return self.stack.get(self.stackPtr - 1 - dist);
    }

    fn push(self: *VM, val: Value) void {
        self.stack.set(self.stackPtr, val);
        self.stackPtr += 1;
    }

    fn consume(self: *VM) void {
        self.stackPtr -= 1;
    }

    fn binaryOp(self: *VM, op: u8, ip: u32) InterpretResult {
        const b = self.pop();
        const a = self.pop();
        if (a == .F32 and b == .F32) {
            switch (op) {
                '+' => {
                    self.push(Value{ .F32 = a.F32 + b.F32 });
                },
                '-' => {
                    self.push(Value{ .F32 = a.F32 - b.F32 });
                },
                '*' => {
                    self.push(Value{ .F32 = a.F32 * b.F32 });
                },
                '/' => {
                    self.push(Value{ .F32 = a.F32 / b.F32 });
                },
                '<' => {
                    self.push(Value{ .BOOL = a.F32 < b.F32 });
                },
                '>' => {
                    self.push(Value{ .BOOL = a.F32 > b.F32 });
                },
                'l' => {
                    self.push(Value{ .BOOL = a.F32 <= b.F32 });
                },
                'g' => {
                    self.push(Value{ .BOOL = a.F32 >= b.F32 });
                },
                else => unreachable
            }
            return InterpretResult.OK;
        } else {
            self.runtimeError("Operands must be numbers.", ip);
            return InterpretResult.RUNTIME_ERR;
        }
    }

    fn runtimeError(self: *VM, msg: []const u8, ip: u32) void {
        println(msg);

        // const instruction = vm.ip - self.chunk.code - 1;
        const line = self.lines.get(ip);
        print("  @line ");
        println(line);
        // resetStack();
    }

    pub fn run(self: *VM) InterpretResult {
        var chunk = self.chunk;
        var pool = self.constPool;
        const lines = self.lines;

        var ip: u32 = 0;
        while (true) {
            _=disassembleInstruction(chunk, pool, lines, ip);

            const instruction = chunk.get(ip);
            switch (@as(OpCode, @enumFromInt(instruction))) {
                .RETURN => {
                    printValue(self.pop(), true);
                    print("\n");
                    return InterpretResult.OK;
                    // ip += 1;
                },
                .CONST => {
                    const poolIdx = chunk.get(ip + 1);
                    const constVal = pool.get(poolIdx);
                    self.push(constVal);
                    ip += 2;
                },
                .NEG => {
                    switch (self.peek(0)) {
                        .F32 => |val| {
                            self.consume();
                            self.push(Value{ .F32 = -val });
                        },
                        .BOOL, .NULL, .STRING => {
                            self.runtimeError("Operand must be a number.", ip);
                            return InterpretResult.RUNTIME_ERR;
                        }
                    }
                    ip += 1;
                },
                .NEQ => {
                    const b = self.pop();
                    const a = self.pop();
                    const resVal = switch (a) {
                        .BOOL => b != .BOOL or a.BOOL != b.BOOL,
                        .NULL => b != .NULL,
                        .F32 => b != .F32 or a.F32 != b.F32,
                        .STRING => blk: {
                            var strA = a.STRING;
                            const strB = b.STRING;
                            break :blk b != .STRING or !strA.equals(strB.*);
                        }
                    };
                    self.push(Value{ .BOOL = resVal });
                    ip += 1;
                },
                .EQ => {
                    const b = self.pop();
                    const a = self.pop();
                    const resVal = switch (a) {
                        .BOOL => b == .BOOL and a.BOOL == b.BOOL,
                        .NULL => b == .NULL,
                        .F32 => b == .F32 and a.F32 == b.F32,
                        .STRING => blk: {
                            var strA = a.STRING;
                            const strB = b.STRING;
                            break :blk b == .STRING and strA.equals(strB.*);
                        }
                    };
                    self.push(Value{ .BOOL = resVal });
                    ip += 1;
                },
                .ADD => {
                    const peekA = self.peek(0);
                    const peekB = self.peek(1);
                    if (peekA == .STRING and peekB == .STRING) {
                        // if () {
                            self.consume();
                            self.consume();
                            const strA = peekA.STRING;
                            const strB = peekB.STRING;
                            var heapStr = String.new(strA.len() + strB.len());
                            self.strings.append(heapStr);
                            heapStr.concat(strA.*);
                            heapStr.concat(strB.*);
                            self.push(Value{ .STRING = heapStr });
                            ip += 1;
                        // }
                    } else {
                        const interpretRes = self.binaryOp('+', ip);
                        if (interpretRes != InterpretResult.OK) {
                            return interpretRes;
                        }
                        ip += 1;
                    }
                },
                .SUB => {
                    const interpretRes = self.binaryOp('-', ip);
                    if (interpretRes != InterpretResult.OK) {
                        return interpretRes;
                    }
                    ip += 1;
                },
                .MUL => {
                    const interpretRes = self.binaryOp('*', ip);
                    if (interpretRes != InterpretResult.OK) {
                        return interpretRes;
                    }
                    ip += 1;
                },
                .DIV => {
                    const interpretRes = self.binaryOp('/', ip);
                    if (interpretRes != InterpretResult.OK) {
                        return interpretRes;
                    }
                    ip += 1;
                },
                .LT => {
                    const interpretRes = self.binaryOp('<', ip);
                    if (interpretRes != InterpretResult.OK) {
                        return interpretRes;
                    }
                    ip += 1;
                },
                .GT => {
                    const interpretRes = self.binaryOp('>', ip);
                    if (interpretRes != InterpretResult.OK) {
                        return interpretRes;
                    }
                    ip += 1;
                },
                .LTE => {
                    const interpretRes = self.binaryOp('l', ip);
                    if (interpretRes != InterpretResult.OK) {
                        return interpretRes;
                    }
                    ip += 1;
                },
                .GTE => {
                    const interpretRes = self.binaryOp('g', ip);
                    if (interpretRes != InterpretResult.OK) {
                        return interpretRes;
                    }
                    ip += 1;
                },
                .NULL => {
                    self.push(Value{ .NULL = undefined });
                    ip += 1;
                },
                .TRUE => {
                    self.push(Value{ .BOOL = true });
                    ip += 1;
                },
                .FALSE => {
                    self.push(Value{ .BOOL = false });
                    ip += 1;
                },
                .NOT => {
                    switch (self.peek(0)) {
                        .BOOL => |val| {
                            self.consume();
                            self.push(Value{ .BOOL = !val });
                        },
                        .NULL => {
                            self.consume();
                            self.push(Value{ .BOOL = true });
                        },
                        .F32, .STRING => {
                            self.runtimeError("Operand must be a boolean or null.", ip);
                            return InterpretResult.RUNTIME_ERR;
                        },
                    }
                    ip += 1;
                },
                // else => {
                //     print("Unknown opcode");
                //     println(instruction);
                //     return offset + 1;
                // }
            }

            const showStack = true;
            if (showStack) {
                println(">>");
                var stackIdx: u32 = 0;
                while (stackIdx < self.stackPtr) : (stackIdx += 1) {
                    print("  ");
                    printValue(self.stack.get(stackIdx), false);
                }
                println("<<");
            }
        }
    }
};
