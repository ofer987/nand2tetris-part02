# frozen_string_literal: true

module VMTranslator
  class Argument < RAM
    # def self.pop
    #   statements = []
    #   pop = <<~COMMAND
    #     // Store the value of RAM[#{ARGUMENT_ADDRESS_LOCATION}] into the D Register
    #     #{ARGUMENT_ADDRESS_LOCATION}
    #     D=M
    #   COMMAND
    #
    #   statements.concat pop.split("\n")
    #   statements << "\n"
    #
    #   statements
    # end
    #
    # def self.push
    #   statements = []
    #   push = <<~COMMAND
    #     // Store the value of the D Register into RAM[#{ARGUMENT_ADDRESS_LOCATION}]
    #     @#{ARGUMENT_ADDRESS_LOCATION}
    #     M=D
    #   COMMAND
    #
    #   statements.concat push.split("\n")
    #   statements << "\n"
    #
    #   statements
    # end

    attr_reader :vm_stack

    def address
      ARGUMENT_ADDRESS_LOCATION
    end
  end
end
