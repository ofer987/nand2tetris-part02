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

    def self.pop_value(address)
      pop = <<~COMMAND
        // Pop the value of the RAM's address into the D Register
        @#{address}
        D=M
      COMMAND

      puts pop.chomp
      puts
    end

    attr_reader :vm_stack

    def address_local
      raise NotImplementedError
    end

    def ram_index
      raise NotImplementedError
    end

    def initialize
      @go_to_counter = 0
    end

    # Set the D Register the value of the Memory Segment
    def pop(indexed_address)
      validate_memory_address(indexed_address)

      command = <<~COMMAND
        // Set the D Register the value of the #{self.class} Memory Segment
        @#{indexed_address}
        D=A

        @#{address_local}
        A=M+D
        D=M
      COMMAND
      puts command.chomp
      puts

      increment_go_to_counter
    end

    # Set RAM to value that had been previously popped from Stack
    def push(indexed_address)
      validate_memory_address(indexed_address)

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
      puts command.chomp
      puts

      increment_go_to_counter
    end

    def reset_pointer(address)
      command = <<~COMMAND
        // Reset the pointer of #{self.class} to #{address}
        @#{address}
        D=A

        @#{address_local}
        M=D
      COMMAND

      puts command.chomp
      puts
    end

    def set(indexed_address, value)
      command = <<~COMMAND
        // Set the value of Address (#{address_local + indexed_address}) to Value (#{value})
        @#{value}
        D=A

        @#{address_local + indexed_address}
        M=D
      COMMAND

      puts command.chomp
      puts
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

    attr_reader :go_to_counter
  end
end
