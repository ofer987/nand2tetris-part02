# frozen_string_literal: true

module VMTranslator
  class Static < RAM
    attr_reader :vm_stack

    def address_local
      THIS_ADDRESS_LOCATION
    end

    def pop(indexed_address)
      validate_memory_address(indexed_address)

      statements = []
      command = <<~COMMAND
        // Set the D Register the value of the Memory Segment
        @#{label(indexed_address)}
        D=M
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      increment_go_to_counter

      statements
    end

    def push(indexed_address)
      validate_memory_address(indexed_address)

      statements = []
      command = <<~COMMAND
        // Set the D Register to the value of the Stack
        @#{STACK_ADDRESS_LOCATION}
        A=M
        D=M

        // Set the M Pointer of #{label(indexed_address)} Memory Segment to the value of the D Register
        @#{label(indexed_address)}
        M=D
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      increment_go_to_counter

      statements
    end

    private

    def label(indexed_address)
      "Foo.$#{indexed_address}"
    end
  end
end
