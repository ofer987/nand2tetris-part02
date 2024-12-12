# frozen_string_literal: true

module VMTranslator
  class That < RAM
    def self.pop
      statements = []
      pop = <<~COMMAND
        // Store the value of RAM[#{THAT_ADDRESS_LOCATION}] into the D Register
        #{THAT_ADDRESS_LOCATION}
        D=M
      COMMAND

      statements.concat pop.split("\n")
      statements << "\n"

      statements
    end

    def self.push
      statements = []
      push = <<~COMMAND
        // Store the value of the D Register into RAM[#{THAT_ADDRESS_LOCATION}]
        @#{THAT_ADDRESS_LOCATION}
        M=D
      COMMAND

      statements.concat push.split("\n")
      statements << "\n"

      statements
    end

    attr_reader :vm_stack

    def address_local
      THAT_ADDRESS_LOCATION
    end
  end
end
