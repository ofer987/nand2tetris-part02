# frozen_string_literal: true

module VMTranslator
  class Function
    FIRST_FUNCTION_START_ADDRESS_INDEX = 1_000

    START_THIS_ADDRESS_INDEX = 5_000
    START_THAT_ADDRESS_INDEX = 6_000
    # THIS_ADDRESS_SPACE_SIZE = 1_000
    # THAT_ADDRESS_SPACE_SIZE = 1_000

    RETURN_REGEX = /^return/

    attr_reader :name, :argument_total
    attr_accessor :local_total

    # Reserve at at least one argument for the return value
    def argument_total=(value)
      @argument_total = value
    end

    def ram_initialized?
      true &&
        @is_local_ram_initialized &&
        @is_argument_ram_initialized &&
        @is_this_ram_initialized &&
        @is_that_ram_initialized
    end

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
    #
    # def body_statements
    #   return @body_statements if defined? @body_statements
    #
    #   @body_statements = end_body_index.times.map do |index|
    #     @body[index]
    #   end
    # end

    def initialize_local_ram(local_ram, temp_ram)
      statements = []

      local_ram_loop_init_label = "INIT_LOCAL_RAM_LOOP_FOR_FUNCTION_#{name}_LABEL"
      exit_local_ram_loop_init_label = "EXIT_INIT_LOCAL_RAM_LOOP_FOR_FUNCTION_#{name}_LABEL"

      statements.concat local_ram.value
      statements.concat temp_ram.push(0)
      statements << "\n"

      asm_loop = <<~ASM_LOOP
        (#{local_ram_loop_init_label})
          @#{VMTranslator::RAM::LOCAL_ADDRESS_LOCATION}
          D=M

          @#{VMTranslator::RAM::STACK_ADDRESS_LOCATION}
          D=M-D

          @#{exit_local_ram_loop_init_label}
          D;JEQ

          @#{VMTranslator::RAM::LOCAL_ADDRESS_LOCATION}
          A=M
          M=0

          @#{VMTranslator::RAM::LOCAL_ADDRESS_LOCATION}
          M=M+1

          @#{local_ram_loop_init_label}
          0;JMP
        (#{exit_local_ram_loop_init_label})
      ASM_LOOP

      statements.concat asm_loop.split("\n")
      statements << "\n"

      statements.concat temp_ram.pop(0)
      statements.concat local_ram.set_value_to_d_register
      statements << "\n"

      statements
    end

    def initialize(name)
      @name = name
    end

    # def allocate_ram(start_ram_address_space_index, argument_total)
    #   # return if @is_ram_initialized
    #
    #   @start_ram_address_space_index = start_ram_address_space_index + 1
    #   local_total = count_local_total
    #
    #   @start_local_address_index = @start_ram_address_space_index
    #   @start_argument_address_index = @start_local_address_index + local_total
    #   @start_this_address_index = @start_argument_address_index + argument_total
    #   @start_that_address_index = @start_this_address_index + THIS_ADDRESS_SPACE_SIZE
    #
    #   @is_ram_allocated = true
    #
    #   # decrement by one because RAM addresses are 0-based indexed
    #   @end_ram_address_space_index = @start_that_address_index +
    #                                  THAT_ADDRESS_SPACE_SIZE -
    #                                  1
    # rescue StandardError => e
    #   puts "Error: Failed to allocate memory for function (#{name}), because #{e}"
    #   puts e.backtrace
    #
    #   exit 1
    # end

    def initialize_argument_ram(stack, ram, argument_total)
      @argument_total = argument_total

      statements = []
      statements.concat stack.pointer
      # TODO: use reset_pointer_by_new_address
      statements.concat VMTranslator::Argument.push

      argument_total.times.each do |index|
        # TODO: use object method instead of class method
        statements.concat VMTranslator::Stack.pop(5 + argument_total + 1 + index)
        statements.concat ram.push(index)
      end

      # What is this for?
      statements.concat VMTranslator::Stack.push

      @is_argument_ram_initialized = true
      statements
    rescue StandardError => e
      puts "Error: Program crashed: #{e}"
      puts e.backtrace

      exit 1
    end

    def initialize_this_ram(constant_ram)
      statements = []
      statements.concat constant_ram.pop(START_THIS_ADDRESS_INDEX)
      statements.concat VMTranslator::This.push

      @is_this_ram_initialized = true
      statements
    rescue StandardError => e
      puts "Error: Program crashed: #{e}"
      puts e.backtrace

      exit 1
    end

    def initialize_that_ram(constant_ram)
      statements = []
      statements.concat constant_ram.pop(START_THAT_ADDRESS_INDEX)
      statements.concat VMTranslator::That.push

      @is_that_ram_initialized = true
      statements
    rescue StandardError => e
      puts "Error: Program crashed: #{e}"
      puts e.backtrace

      exit 1
    end

    def label
      @label ||= "(#{name})"
    end

    def return_label
      "#{name}$#{@return_counter}"
    end

    def increment_return_counter
      @return_counter += 1
    end

    private

    def end_body_index
      return @end_body_index if defined? @end_body_index

      index = 0
      body.each do |line|
        if line.match? RETURN_REGEX
          @end_body_index = index

          return @end_body_index
        end

        index += 1
      end
    end

    attr_reader :body
  end
end
