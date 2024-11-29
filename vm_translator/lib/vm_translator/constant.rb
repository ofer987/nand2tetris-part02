# frozen_string_literal: true

module VMTranslator
  class Constant < RAM
    attr_reader :vm_stack

    def pop(indexed_address)
      validate_memory_address(indexed_address)

      command = <<~COMMAND
        @#{indexed_address}
        D=A
      COMMAND

      puts command.chomp
      puts
    end

    def push(_indexed_address)
      raise NotImplementedError
    end
  end
end
