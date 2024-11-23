# frozen_string_literal: true

module VMTranslator
  class Argument < RAM
    attr_reader :vm_stack

    def address_local
      ARGUMENT_ADDRESS_LOCATION
    end
  end
end
