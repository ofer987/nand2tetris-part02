# frozen_string_literal: true

module VMTranslator
  class Temp < RAM
    attr_reader :vm_stack

    def address_local
      TEMP_ADDRESS_LOCATION
    end

    def pop(indexed_address)
      validate_memory_address(indexed_address)

      command = <<~COMMAND
        @#{address_local + indexed_address}
        D=M
      COMMAND

      puts command.chomp
      puts
    end

    def push(indexed_address)
      validate_memory_address(indexed_address)

      command = <<~COMMAND
        @#{address_local + indexed_address}
        M=D
      COMMAND

      puts command.chomp
      puts
    end

    protected

    def validate_memory_address(indexed_address)
      return if indexed_address.positive? && indexed_address <= 7

      raise ArgumentError "(#{indexed_address}) should be between 0 and 7"
    end
  end
end
