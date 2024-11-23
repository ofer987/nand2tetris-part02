# frozen_string_literal: true

module VMTranslator
  class Argument < RAM
    attr_reader :vm_stack

    def address_local
      ARGUMENT_ADDRESS_LOCATION
    end

    def pop(indexed_address)
      validate_memory_address(indexed_address)

      command = <<~COMMAND
        @#{address_local + indexed_address}
        D=M
      COMMAND

      puts command.chomp
    end
  end
end
