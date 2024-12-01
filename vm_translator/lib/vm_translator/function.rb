# frozen_string_literal: true

module VMTranslator
  class Function
    RETURN_REGEX = /^return/

    attr_reader :name

    def initialize(name, body)
      @name = name
      @body = Array(body)
      @end_body_index = 0
      @return_counter = 0

      dedicate_local
    end

    def initialize_local_ram(constant_ram, local_ram)
      count_local_total.times.each do |index|
        constant_ram.pop(0)

        local_ram.push(index)
      end
    end

    def count_local_total
      return @count_local_total if defined? @count_local_total

      local_variable_address_indices = body[..find_end_body_index]
        .select { |line| line.match? line.match? VMTranslator::Commands::LOCAL_REGEX }
        .map { |line| line.match(VMTranslator::Commands::LOCAL_REGEX)[1].to_i }

      total = Array(local_variable_address_indices).max
      @count_local_total = total unless total.nil?
    end

    def return_label
      "#{name}$#{@return_counter}"
    end

    def increment_return_counter
      @return_counter += 1
    end

    private

    def find_end_body_index
      return @find_end_body_index if defined? @find_end_body_index

      index = 0
      @body.each do |line|
        if line.match? RETURN_REGEX
          @find_end_body_index = index

          return @find_end_body_index
        end

        index += 1
      end
    end
  end
end
