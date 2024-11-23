# frozen_string_literal: true

module VMTranslator
  class This < RAM
    attr_reader :vm_stack

    def address_local
      THIS_ADDRESS_LOCATION
    end
  end
end
