# frozen_string_literal: true

module VMTranslator
  class Local < RAM
    attr_reader :vm_stack

    def address_local
      LOCAL_ADDRESS_LOCATION
    end
  end
end
