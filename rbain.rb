#!/usr/bin/ruby
require 'io/console'

module Rbain
  class Memory
    attr_accessor :ptr, :table

    def initialize(s = 30_000)
      @table = Array.new(s, 0)
      @ptr = 0
    end

    def ptrinc
      @ptr += 1
    end

    def ptrdec
      @ptr -= 1
    end

    def posinc
      @table[@ptr] += 1
    end

    def posdec
      @table[@ptr] -= 1
    end

    def value
      check_ptr
      @table[@ptr]
    end

    def set(v)
      @table[@ptr] = v
    end

    def check_ptr
      raise "Attempting to index value outside of tape! length: #{@table.count - 1} pointer: #{@ptr}" if ptr < 0 || ptr > table.count - 1
    end
  end

  class Interpreter
    def initialize(program)
      @mem = Memory.new
      @program = program
      @jump = parse_loops
    end

    def parse_loops
      stack = []
      jump = []
      @program.each_char.with_index do |e, ix|
        if e == '['
          stack.append(ix)
        elsif e == ']'
          raise 'found ] without [' if stack.empty?
          jump[ix] = stack.pop()
          jump[jump[ix]] = ix
        end
      end
      raise 'found [ without ]' if !stack.empty?
      jump
    end

    def run
      i = 0

      while i < @program.length do
        case @program[i]
          when '>'
            @mem.ptrinc
          when '<'
            @mem.ptrdec
          when '+'
            @mem.posinc
          when '-'
            @mem.posdec
          when '.'
            print @mem.value.chr
          when ','
            @mem.set(STDIN.noecho(&:getch).ord)
          when '['
              i = @jump[i] if @mem.value == 0
          when ']'
              i = @jump[i]  if @mem.value != 0
        end
        i += 1
      end
    end
  end

  class << self 
    def interpret(code)
      Interpreter.new(code).run
    end

    def interpret_file(path)
      code = File.open(path).read
      Rbain.interpret(code)
    end
  end
end

def help
  str = "BRAINFUCK interpreter written in Ruby
Example: './rbain.rb 'brainuck_code'\n
-f |   ./rbain.rb -f 'path'  | Interprete file
-h |   Display help message\n"

  puts str
end

if ARGV.count == 1 && ARGV[0] == "-h" || !(1..2).include?(ARGV.count)
  help
end

if ARGV.count == 2 && ARGV[0] == "-f"
  Rbain.interpret_file(ARGV[1])
end

if ARGV.count == 1
  Rbain.interpret(ARGV[0])
end