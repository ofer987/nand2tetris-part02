# frozen_string_literal: true

module VMTranslator
  # class Stack < RAM
  class RAM
    STACK_ADDRESS_LOCATION = 0
    STACK_START_RAM_INDEX = 256

    attr_reader :vm_stack

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
