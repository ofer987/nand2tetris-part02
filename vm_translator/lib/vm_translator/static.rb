# frozen_string_literal: true

module VMTranslator
  class Static < RAM
    attr_reader :vm_stack, :available_address

    FIRST_ADDRESS = 16
    LAST_ADDRESS = 255

    def self.variable_name(klazz_name, address)
      unless (address + 16) >= FIRST_ADDRESS && (address + 16) <= LAST_ADDRESS
        raise "Address (#{address}) should should be between #{FIRST_ADDRESS - 16} and #{LAST_ADDRESS - 16}"
      end

      "#{klazz_name}.#{address}"
    end

    def address
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

    def set_address(klazz_name, address)
      unless (@available_address + 16) >= FIRST_ADDRESS && (@available_address + 16) <= LAST_ADDRESS
        raise 'No more static memory available!'
      end

      name = "#{klazz_name}.#{address}"

      increment_available_address

      name
    end

    def increment_available_address
      @available_address += 1
    end

    def initialize
      super

      @available_address = 16
    end

    private

    def label(indexed_address)
      "Foo.$#{indexed_address}"
    end
  end
end
