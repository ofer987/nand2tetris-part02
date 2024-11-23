# frozen_string_literal: true

module VMTranslator
  class Constant < RAM
    attr_reader :vm_stack

    def ram_index
      raise NotImplementedError
    end

    def pop(_value)
      # raise NotImplementedError
    end

    def push(_value)
      # raise NotImplementedError
    end
  end
end
