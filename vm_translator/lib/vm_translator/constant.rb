# frozen_string_literal: true

module VMTranslator
  class Constant < RAM
    attr_reader :vm_stack

    def pop(indexed_address)
      validate_memory_address(indexed_address)

      statements = []
      command = <<~COMMAND
        // Set the D Register the value of the #{self.class} Memory Segment
        @#{indexed_address}
        D=A
      COMMAND

      statements.concat command.split("\n")
      statements << "\n"

      statements
    end

    def push(_indexed_address)
      raise NotImplementedError
    end
  end
end
