# frozen_string_literal: true

module VMTranslator
  class Static < RAM
    attr_reader :vm_stack, :available_address

    FIRST_ADDRESS = 16
    LAST_ADDRESS = 255

    def self.variable_name(klazz_name, address)
      unless (address + 16) >= FIRST_ADDRESS && (address + 16) <= LAST_ADDRESS
        raise "Address (#{address}) should should be between #{FIRST_ADDRESS - 16} and #{LAST_ADDRESS - 16}"
      end

      "#{klazz_name}.#{address}"
    end

    def address
      THIS_ADDRESS_LOCATION
    end

    def pop(label)
      statements = []
      command = <<~COMMAND
        // Set the D Register the value of the Memory Segment
        @#{label}
        D=M
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      increment_go_to_counter

      statements
    end

    def push(label)
      statements = []
      command = <<~COMMAND
        // Set the D Register to the value of the Stack
        @#{STACK_ADDRESS_LOCATION}
        A=M
        D=M

        // Set the M Pointer of #{label} Memory Segment to the value of the D Register
        @#{label}
        M=D
      COMMAND
      statements.concat command.split("\n")
      statements << "\n"

      increment_go_to_counter

      statements
    end

    def label(klazz_name, address_index)
      "#{klazz_name}.$#{address_index}"

      # raise "Static address #{name} has not been reserved" unless @reserved_labels.key? name
    end

    def get_reserved_label(klazz_name, address_index)
      name = label(klazz_name, address_index)
      raise "Static address #{name} has not been reserved" unless @reserved_labels.key? name

      name
    end

    def set_label(klazz_name, address_index)
      new_label = label(klazz_name, address_index)
      return if @reserved_labels.key? new_label

      unless @available_address >= FIRST_ADDRESS && @available_address <= LAST_ADDRESS
        raise 'No more static memory available!'
      end

      @reserved_labels[new_label] = @available_address
      increment_available_address

      new_label
    end

    def initialize
      super

      @reserved_labels = {}
      @available_address = 16
    end

    private

    def increment_available_address
      @available_address += 1
    end
  end
end
