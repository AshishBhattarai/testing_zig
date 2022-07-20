const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const InstructionType = enum(u8) {
    SELECT_PEN = 'P',
    PEN_DOWN = 'D',
    DRAW_WEST = 'W',
    DRAW_NORTH = 'N',
    DRAW_EAST = 'E',
    DRAW_SOUTH = 'S',
    PEN_UP = 'U',

    const Self = @This();

    pub fn isValid(value: u8) bool {
        const enum_fields = @typeInfo(InstructionType).Enum.fields;
        inline for (enum_fields) |field| {
            if (field.value == value)
                return true;
        }
        return false;
    }

    pub fn expectsArgument(self: *const Self) bool {
        return switch (self.*) {
            InstructionType.PEN_DOWN => false,
            InstructionType.PEN_UP => false,
            else => true,
        };
    }
};

const InstructionTable = struct { argument: ?u8, type: InstructionType };

const ParserErrors = error{ InvalidInstruction, MissingArugment };

pub const Parser = struct {
    instruction_table: ArrayList(InstructionTable),

    const Self = @This();

    pub fn init() Self {
        return Self{ .instruction_table = ArrayList(InstructionTable).init(allocator) };
    }

    pub fn process(self: *Self, line: []const u8) !void {
        if (line.len <= 0) return;

        const instruction = try decode_intruction(line[0]);
        const expectsArgument = instruction.expectsArgument();
        if (expectsArgument and line.len != 3) return ParserErrors.MissingArugment;
        const argument = if (expectsArgument) line[2] - '0' else null;
        try self.instruction_table.append(InstructionTable{ .argument = argument, .type = instruction });
    }

    fn decode_intruction(instruction: u8) !InstructionType {
        return if (InstructionType.isValid(instruction)) @intToEnum(InstructionType, instruction) else ParserErrors.InvalidInstruction;
    }
};
