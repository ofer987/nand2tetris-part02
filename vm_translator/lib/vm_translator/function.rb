# frozen_string_literal: true

module VMTranslator
  class Function
    attr_reader :name
    attr_accessor :local_total, :argument_total

    def execute
      statements = []

      command = <<~COMMAND
        @#{name}
        0;JMP
      COMMAND

      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    def reset_stack_pointer_to_argument_second_approach
      statements = []

      command_loop = <<~COMMAND
        // Place the Return Pointer into the address of ARGUMENT_RAM
        @#{VMTranslator::RAM::ARGUMENT_ADDRESS_LOCATION}
        A=M
        D=A

        @#{argument_total}
        D=D+A
        A=D
        D=M

        @#{VMTranslator::RAM::ARGUMENT_ADDRESS_LOCATION}
        A=M
        M=D
      COMMAND

      statements.concat command_loop.split("\n")
      statements << "\n"
    end

    def initialize_local_ram(total)
      statements = []

      local_ram_loop_init_label = "INIT_LOCAL_RAM_LOOP_FOR_FUNCTION_#{name}_LABEL"
      exit_local_ram_loop_init_label = "EXIT_INIT_LOCAL_RAM_LOOP_FOR_FUNCTION_#{name}_LABEL"

      asm_loop = <<~ASM_LOOP
        (#{local_ram_loop_init_label})
          @#{VMTranslator::RAM::LOCAL_ADDRESS_LOCATION}
          D=M

          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          D=M-D

          @#{total}
          D=D-A

          @#{exit_local_ram_loop_init_label}
          D;JEQ

          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          A=M
          M=0

          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          M=M+1

          @#{local_ram_loop_init_label}
          0;JMP
        (#{exit_local_ram_loop_init_label})
      ASM_LOOP

      statements.concat asm_loop.split("\n")
      statements << "\n"

      statements
    end

    def initialize(name)
      @name = name
      @return_counter = 0

      @local_total = 0
      @argument_total = 0
    end

    def label
      @label ||= "(#{name})"
    end

    def return_label
      "#{name}$ret.#{@return_counter}"
    end

    def increment_return_counter
      @return_counter += 1
    end

    private

    attr_reader :body
  end
end
