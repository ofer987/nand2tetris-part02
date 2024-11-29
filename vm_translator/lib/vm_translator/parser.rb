#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'

module VMTranslator
  class Parser
    def put_start_program
      output = <<~START_PROGRAM
        (START)
        @#{VMTranslator::RAM::STACK_RAM_INDEX}
        D=A

        @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
        M=D
      START_PROGRAM

      puts output.chomp
    end

    def put_end_program
      output = <<~END_PROGRAM
        (END)

        @END
        0;JMP
      END_PROGRAM

      puts output.chomp
    end

    def initialize
      # binding.pry
      @program_counter = 0
      @stack = VMTranslator::Stack.new
      @constant_ram = VMTranslator::Constant.new
      @local_ram = VMTranslator::Local.new
      @argument_ram = VMTranslator::Argument.new
      @this_ram = VMTranslator::This.new
      @that_ram = VMTranslator::That.new
      @temp_ram = VMTranslator::Temp.new
      @pointer_ram = VMTranslator::Pointer.new
      @static_ram = VMTranslator::Static.new
    end

    def parse(line)
      # binding.pry
      if line.match? VMTranslator::Commands::PUSH_REGEX
        inner_match = line.match(VMTranslator::Commands::PUSH_REGEX)[1].to_s

        ram, value = parse(inner_match)
        ram.pop(value)
        stack.push(value)
      elsif line.match? VMTranslator::Commands::POP_REGEX
        inner_match = line.match(VMTranslator::Commands::POP_REGEX)[1].to_s

        ram, value = parse(inner_match)
        stack.pop(value)
        ram.push(value)
      elsif line.match? VMTranslator::Commands::CONSTANT_REGEX
        value = line.match(VMTranslator::Commands::CONSTANT_REGEX)[1].to_i

        [constant_ram, value]
      elsif line.match? VMTranslator::Commands::LOCAL_REGEX
        value = line.match(VMTranslator::Commands::LOCAL_REGEX)[1].to_i

        [local_ram, value]
      elsif line.match? VMTranslator::Commands::ARGUMENT_REGEX
        value = line.match(VMTranslator::Commands::ARGUMENT_REGEX)[1].to_i

        [argument_ram, value]
      elsif line.match? VMTranslator::Commands::THIS_REGEX
        value = line.match(VMTranslator::Commands::THIS_REGEX)[1].to_i

        [this_ram, value]
      elsif line.match? VMTranslator::Commands::THAT_REGEX
        value = line.match(VMTranslator::Commands::THAT_REGEX)[1].to_i

        [that_ram, value]
      elsif line.match? VMTranslator::Commands::TEMP_REGEX
        value = line.match(VMTranslator::Commands::TEMP_REGEX)[1].to_i

        [temp_ram, value]
      elsif line.match? VMTranslator::Commands::POINTER_REGEX
        value = line.match(VMTranslator::Commands::POINTER_REGEX)[1].to_i

        [pointer_ram, value]
      elsif line.match? VMTranslator::Commands::STATIC_REGEX
        value = line.match(VMTranslator::Commands::STATIC_REGEX)[1].to_i

        [static_ram, value]
      elsif line.match? VMTranslator::Commands::ADD_REGEX
        stack.asm_reset_to_zero

        first_value = stack.pop(0)
        stack.add_operation

        second_value = stack.pop(0)
        stack.add_operation

        stack.push(second_value + first_value)
      elsif line.match? VMTranslator::Commands::SUB_REGEX
        stack.asm_reset_to_zero

        first_value = stack.pop(0)
        stack.sub_operation

        second_value = stack.pop(0)
        stack.sub_operation

        stack.push(second_value - first_value)
      elsif line.match? VMTranslator::Commands::EQ_REGEX
        stack.eq
      elsif line.match? VMTranslator::Commands::LT_REGEX
        stack.lt
      elsif line.match? VMTranslator::Commands::GT_REGEX
        stack.gt
      elsif line.match? VMTranslator::Commands::NEG_REGEX
        stack.neg
      elsif line.match? VMTranslator::Commands::AND_REGEX
        stack.asm_reset_to_one

        first_value = stack.pop(0)
        stack.and_operation

        second_value = stack.pop(0)
        stack.and_operation

        stack.push(second_value & first_value)
      elsif line.match? VMTranslator::Commands::OR_REGEX
        stack.asm_reset_to_zero

        first_value = stack.pop(0)
        stack.or_operation

        second_value = stack.pop(0)
        stack.or_operation

        stack.push(second_value | first_value)
      elsif line.match? VMTranslator::Commands::NOT_REGEX
        stack.not
      elsif line.match? VMTranslator::Commands::LABEL_REGEX
        label_name = line.match(VMTranslator::Commands::LABEL_REGEX)[1].to_s

        stack.add_label(label_name, program_counter)
      elsif line.match? VMTranslator::Commands::IF_GO_TO_REGEX
        label_name = line.match(VMTranslator::Commands::IF_GO_TO_REGEX)[1].to_s

        stack.pop(0)
        stack.if_go_to(label_name, argument_ram)
      end
    ensure
      @program_counter += 1 if VMTranslator::Commands.statement?(line)
    end

    private

    attr_reader :stack, :program_counter
    attr_reader :constant_ram, :local_ram, :argument_ram, :this_ram, :that_ram, :temp_ram, :pointer_ram, :static_ram
  end
end
