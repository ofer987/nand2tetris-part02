# frozen_string_literal: true

module VMTranslator
  # class Stack < RAM
  class RAM
    LOCAL_ADDRESS_LOCATION = 1
    # LOCAL_RAM_INDEX = 300

    STACK_ADDRESS_LOCATION = 0
    STACK_RAM_INDEX = 256

    ARGUMENT_ADDRESS_LOCATION = 2
    # ARGUMENT_RAM_INDEX = 400

    THIS_ADDRESS_LOCATION = 3
    # THIS_RAM_INDEX = 3000

    THAT_ADDRESS_LOCATION = 4
    # THAT_RAM_INDEX = 3010

    TEMP_ADDRESS_LOCATION = 5

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

    def pop(indexed_address)
      validate_memory_address

      command = <<~COMMAND
        @#{address_local + indexed_address}
        D=M
      COMMAND

      puts command.chomp
    end

    def push(indexed_address)
      validate_memory_address

      command = <<~COMMAND
        // Retrieve the Popped value from the Stack
        A=M
        D=M

        // Set RAM to value
        @#{address_local + indexed_address}
        M=D
      COMMAND
      puts command.chomp

      increment_go_to_counter
    end

    protected

    def validate_memory_address(_indexed_address); end

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
