# frozen_string_literal: true

module VMTranslator
  class This < RAM
    # def self.pop
    #   statements = []
    #   pop = <<~COMMAND
    #     // Store the value of RAM[#{THIS_ADDRESS_LOCATION}] into the D Register
    #     #{THIS_ADDRESS_LOCATION}
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
    #     // Store the value in the D Register into RAM[#{THIS_ADDRESS_LOCATION}]
    #     @#{THIS_ADDRESS_LOCATION}
    #     M=D
    #   COMMAND
    #
    #   statements.concat push.split("\n")
    #   statements << "\n"
    #
    #   statements
    # end

    attr_reader :vm_stack

    def address_local
      THIS_ADDRESS_LOCATION
    end
  end
end
