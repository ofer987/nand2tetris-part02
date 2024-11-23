# frozen_string_literal: true

module VMTranslator
  class That < RAM
    attr_reader :vm_stack

    def address_local
      THAT_ADDRESS_LOCATION
    end
  end
end
