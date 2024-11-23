# frozen_string_literal: true

module VMTranslator
  class Temp < RAM
    attr_reader :vm_stack

    def address_local
      TEMP_ADDRESS_LOCATION
    end

    def pop(value)
      raise ArgumentError "Value (#{value}) should be between 0 and 7" if value.negative? || value > 7

      command = <<~COMMAND
        @#{address_local + value}
        D=A
      COMMAND

      puts command.chomp
    end

    def push(value)
      raise ArgumentError "Value (#{value}) should be between 0 and 7" if value.negative? || value > 7

      command = <<~COMMAND
        // Set RAM to value
        @#{address_local} + value
        M=D
      COMMAND
      puts command.chomp
      vm_stack.pop

      increment_go_to_counter
    end
  end
end
