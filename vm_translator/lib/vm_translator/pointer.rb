# frozen_string_literal: true

module VMTranslator
  class Pointer < RAM
    attr_reader :vm_stack

    def address_local
      THIS_ADDRESS_LOCATION
    end

    def pop(indexed_address)
      validate_memory_address(indexed_address)

      command = <<~COMMAND
        // Set the D Register the value of the Memory Segment
        @#{address_local + indexed_address}
        D=M
      COMMAND
      puts command.chomp

      increment_go_to_counter
    end

    def push(indexed_address)
      validate_memory_address(indexed_address)

      command = <<~COMMAND
        // Set the M Pointer of #{self.class} Memory Segment to the value of #{address_local} + #{indexed_address}
        @#{address_local + indexed_address}
        M=D
      COMMAND
      puts command.chomp

      increment_go_to_counter
    end

    protected

    def validate_memory_address(indexed_address)
      raise ArgumentError "(#{indexed_address}) should be either 0 or 1" unless [0, 1].include? indexed_address
    end
  end
end
