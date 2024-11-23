# frozen_string_literal: true

module VMTranslator
  class Local < RAM
    attr_reader :vm_stack

    def address_local
      LOCAL_ADDRESS_LOCATION
    end

    def ram_index
      raise NotImplementedError
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
