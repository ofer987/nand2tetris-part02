# frozen_string_literal: true

module VMTranslator
  class This < RAM
    def self.pop
      pop = <<~COMMAND
        // Store the value of RAM[#{THIS_ADDRESS_LOCATION}] into the D Register
        #{THIS_ADDRESS_LOCATION}
        D=M
      COMMAND

      puts pop.chomp
      puts
    end

    def self.push
      push = <<~COMMAND
        // Store the value in the D Register into RAM[#{THIS_ADDRESS_LOCATION}]
        @#{THIS_ADDRESS_LOCATION}
        M=D
      COMMAND

      puts push.chomp
      puts
    end

    attr_reader :vm_stack

    def address_local
      THIS_ADDRESS_LOCATION
    end
  end
end
