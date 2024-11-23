# frozen_string_literal: true

module VMTranslator
  class That < RAM
    attr_reader :vm_stack

    def address_local
      THAT_ADDRESS_LOCATION
    end

    def pop(value)
      command = <<~COMMAND
        @#{value}
        D=A
      COMMAND

      puts command.chomp
    end

    def push(_value)
      # raise NotImplementedError
    end
  end
end
