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
      @table[@ptr]
    end
  end

  class Interpreter
    def initialize(program)
      @mem = Memory.new
      @program = program
    end

    def run
      i = 0

      stack = []
      jump = []
      @program.each_char.with_index do |e, ix|
        if e == '['
          stack.append(ix)
        elsif e == ']'
          jump[ix] = stack.pop()
          jump[jump[ix]] = ix
        end
      end

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
            @mem.table[i] = STDIN.noecho(&:getch).ord
          when '['
            if @mem.value == 0
              i = jump[i]
            end
          when ']'
            if @mem.value > 0
              i = jump[i]
            end
        end
        i += 1
      end
    end
  end

  class << self 
    def interpret(code)
      Interpreter.new(code).run
    end
  end
end

Rbain.interpret(">+++++++++[<++++++++>-]<.>+++++++[<++++>-]<+.+++++++..+++.[-]>++++++++[<++++>-] <.>+++++++++++[<++++++++>-]<-.--------.+++.------.--------.[-]>++++++++[<++++>- ]<+.[-]++++++++++.")