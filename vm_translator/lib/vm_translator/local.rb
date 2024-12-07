# frozen_string_literal: true

module VMTranslator
  class Local < RAM
    def self.pop
      statements = []
      pop = <<~COMMAND
        // Store the value of RAM[#{LOCAL_ADDRESS_LOCATION}] into the D Register
        #{LOCAL_ADDRESS_LOCATION}
        D=M
      COMMAND

      statements.concat pop.split("\n")
      statements
    end

    def self.push
      statements = []
      push = <<~COMMAND
        // Store the value of the D Register into RAM[#{LOCAL_ADDRESS_LOCATION}]
        @#{LOCAL_ADDRESS_LOCATION}
        M=D
      COMMAND

      statements.concat push.split("\n")
      statements
    end

    attr_reader :vm_stack

    def address_local
      LOCAL_ADDRESS_LOCATION
    end
  end
end
