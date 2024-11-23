# frozen_string_literal: true

module VMTranslator
  # class Stack < RAM
  class RAM
    LOCAL_ADDRESS_LOCATION = 1
    LOCAL_RAM_INDEX = 1015

    STACK_ADDRESS_LOCATION = 0
    STACK_RAM_INDEX = 256

    ARGUMENT_ADDRESS_LOCATION = 2
    ARGUMENT_RAM_INDEX = 256

    THIS_ADDRESS_LOCATION = 3
    THIS_RAM_INDEX = 256

    THAT_ADDRESS_LOCATION = 4
    THAT_RAM_INDEX = 256

    TEMP_ADDRESS_LOCATION = 5
    TEMP_RAM_INDEX = 256

    attr_reader :vm_stack

    def address_local
      raise NotImplementedError
    end

    def ram_index
      raise NotImplementedError
    end

    def initialize
      @go_to_counter = 0
    end

    def push(value)
      # binding.pry

      command = <<~COMMAND
        @#{Stack::STACK_ADDRESS_LOCATION}
        A=M

        // Set RAM to value
        M=D
      COMMAND
      puts command.chomp
      vm_stack.push(value)

      increment_stack = <<~COMMAND
        @#{Stack::STACK_ADDRESS_LOCATION}
        M=M+1
      COMMAND
      puts increment_stack.chomp

      increment_go_to_counter
    end

    private

    def go_to
      @go_to ||= 'GO_TO'
    end

    def go_to_if_true
      "#{go_to}_#{self.class}_if_true_#{go_to_counter}"
    end

    def go_to_end
      "#{go_to}_#{self.class}_end_#{go_to_counter}"
    end

    def increment_go_to_counter
      @go_to_counter += 1
    end

    attr_reader :go_to_counter
  end
end
