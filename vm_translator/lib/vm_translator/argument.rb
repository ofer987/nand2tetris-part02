# frozen_string_literal: true

module VMTranslator
  class Argument < RAM
    def self.pop
      pop = <<~COMMAND
        // Store the value of RAM[#{ARGUMENT_ADDRESS_LOCATION}] into the D Register
        #{ARGUMENT_ADDRESS_LOCATION}
        D=M
      COMMAND

      puts pop.chomp
      puts
    end

    def self.push
      push = <<~COMMAND
        // Store the value of the D Register into RAM[#{ARGUMENT_ADDRESS_LOCATION}]
        @#{ARGUMENT_ADDRESS_LOCATION}
        M=D
      COMMAND

      puts push.chomp
      puts
    end

    attr_reader :vm_stack

    def address_local
      ARGUMENT_ADDRESS_LOCATION
    end
  end
end
