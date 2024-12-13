# frozen_string_literal: true

module VMTranslator
  # class Stack < RAM
  class RAM
    LOCAL_ADDRESS_LOCATION = 1

    STACK_ADDRESS_LOCATION = 0
    STACK_RAM_INDEX = 256

    ARGUMENT_ADDRESS_LOCATION = 2

    THIS_ADDRESS_LOCATION = 3

    THAT_ADDRESS_LOCATION = 4

    TEMP_ADDRESS_LOCATION = 5

    # def self.pop_value(address)
    #   pop = <<~COMMAND
    #     // Pop the value of the RAM's address into the D Register
    #     @#{address}
    #     D=M
    #   COMMAND
    #
    #   puts pop.chomp
    #   statements << "\n"
    # end
    #
    # def self.push_value(address)
    #   pop = <<~COMMAND
    #     // Push the value of the D Register into
    #     @#{address}
    #     M=D
    #   COMMAND
    #
    #   puts pop.chomp
    #   statements << "\n"
    # end

    attr_reader :vm_stack

    def address_local
      raise NotImplementedError
    end

    def ram_index
      raise NotImplementedError
    end

    def initialize(address_local: nil, address_space_size: nil)
      @go_to_counter = 0

      @address_local = address_local unless address_local.nil?
      @address_space_size = address_space_size unless address_space_size.nil?
    end

    # TODO: Rename
    def set_first_memory_register_to_d_register
      statements = []
      command = <<~COMMAND
        // Set the D Register the value of the #{self.class} Memory Segment
        @#{address_local}
        A=M
        M=D
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    # Set the D Register the value of the Memory Segment
    def pop(indexed_address)
      validate_memory_address(indexed_address)

      statements = []
      command = <<~COMMAND
        // Set the D Register the value of the #{self.class} Memory Segment
        @#{indexed_address}
        D=A

        @#{address_local}
        A=M+D
        D=M
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    # Set RAM to value that had been previously popped from Stack
    def push(indexed_address)
      validate_memory_address(indexed_address)

      statements = []
      command = <<~COMMAND
        // Set the M Pointer of the #{self.class} Memory Segment to the value of #{address_local} + #{indexed_address}
        @#{address_local}
        D=M
        @#{indexed_address}
        D=D+A
        @#{address_local}
        M=D

        // Set the D Register to the value of the Stack
        @#{STACK_ADDRESS_LOCATION}
        A=M
        D=M

        // Set the M Pointer of the #{self.class} Memory Segment to the D Register
        @#{address_local}
        A=M
        M=D

        // Reset the M Pointer of the #{self.class} Memory Segment back to #{address_local}
        @#{indexed_address}
        D=A
        @#{address_local}
        M=M-D
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    def pointer
      statements = []

      command = <<~COMMAND
        // Get the address that #{self.class} points to
        @#{address_local}
        D=M
      COMMAND

      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    def reset_pointer_by_offset(offset)
      statements = []

      command = <<~COMMAND
        // Offset the pointer #{self.class} by #{offset}
        @#{offset}
        D=A

        @#{address_local}
        M=M+D
      COMMAND

      statements.concat command.split("\n")
      statements << "\n"
    end

    def set_value_to_d_register
      statements = []
      command = <<~COMMAND
        // Set the value of #{self.class} to the value in the D Register
        @#{address_local}
        M=D
      COMMAND

      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    def set(indexed_address, value)
      statements = []
      command = <<~COMMAND
        // Set the value of Address (#{address_local + indexed_address}) to Value (#{value})
        @#{value}
        D=A

        @#{address_local + indexed_address}
        M=D
      COMMAND

      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    protected

    def validate_memory_address(_indexed_address); end

    private

    def go_to
      @go_to ||= 'GO_TO'
    end

    def go_to_if_true
      "#{go_to}_#{self.class}_if_true_#{go_to_counter}"
    end

    def go_to_end
      "#{go_to}_#{self.class}_end_#{go_to_counter}"
    end

    def increment_go_to_counter
      @go_to_counter += 1
    end

    def count_lines(command)
      result = command
        .split("\n")
        .map(&:strip)
        .reject(&:empty?)
        .reject { |line| line.start_with? '//' }

      result.size
    end

    attr_reader :go_to_counter
  end
end
