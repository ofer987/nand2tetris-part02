# frozen_string_literal: true

module VMTranslator
  class Function
    FIRST_FUNCTION_START_ADDRESS_INDEX = 1_000

    START_THIS_ADDRESS_INDEX = 5_000
    START_THAT_ADDRESS_INDEX = 6_000
    # THIS_ADDRESS_SPACE_SIZE = 1_000
    # THAT_ADDRESS_SPACE_SIZE = 1_000

    RETURN_REGEX = /^return/

    attr_reader :name,
      :start_ram_address_space_index,
      :end_ram_address_space_index,
      :start_local_address_index,
      :start_argument_address_index,
      :start_this_address_index,
      :start_that_address_index

    def function_initialized?
      @is_ram_allocated && ram_initialized?
    end

    def ram_initialized?
      true &&
        @is_local_ram_initialized &&
        @is_argument_ram_initialized &&
        @is_this_ram_initialized &&
        @is_that_ram_initialized
    end

    def initialize(name, body)
      @name = name
      @body = Array(body)
      @end_body_index = 0
      @return_counter = 0
      @function_index = function_index
      # @start_ram_address_index = start_ram_address_index
      @argument_total = argument_total
      @is_ram_allocated = false

      @is_local_ram_initialized = false
      @is_argument_ram_initialized = false
      @is_this_ram_initialized = false
      @is_that_ram_initialized = false
    end

    def allocate_ram(start_ram_address_space_index, argument_total)
      # return if @is_ram_initialized

      @start_ram_address_space_index = start_ram_address_space_index + 1
      local_total = count_local_total

      @start_local_address_index = @start_ram_address_space_index
      @start_argument_address_index = @start_local_address_index + local_total
      @start_this_address_index = @start_argument_address_index + argument_total
      @start_that_address_index = @start_this_address_index + THIS_ADDRESS_SPACE_SIZE

      @is_ram_allocated = true

      # decrement by one because RAM addresses are 0-based indexed
      @end_ram_address_space_index = @start_that_address_index +
                                     THAT_ADDRESS_SPACE_SIZE -
                                     1
    rescue StandardError => e
      puts "Error: Failed to allocate memory for function (#{name}), because #{e}"
      puts e.backtrace

      exit 1
    end

    def initialize_local_ram(ram)
      local_total = count_local_total
      local_total.times.each do |_index|
        ram.push(0)
      end

      @is_local_ram_initialized = true
    rescue StandardError => e
      puts "Error: Program crashed: #{e}"
      puts e.backtrace

      exit 1
    end

    def initialize_argument_ram(ram, argument_total)
      argument_total.times.each do |index|
        VMTranslator::Stack.pop(5 + argument_total + 1 + index)
        ram.push
      end

      @is_argument_ram_initialized = true
    rescue StandardError => e
      puts "Error: Program crashed: #{e}"
      puts e.backtrace

      exit 1
    end

    def initialize_this_ram
      VMTranslator::This.push(START_THIS_ADDRESS_INDEX)

      @is_this_ram_initialized = true
    rescue StandardError => e
      puts "Error: Program crashed: #{e}"
      puts e.backtrace

      exit 1
    end

    def initialize_that_ram
      VMTranslator::That.push(START_THAT_ADDRESS_INDEX)

      @is_that_ram_initialized = true
    rescue StandardError => e
      puts "Error: Program crashed: #{e}"
      puts e.backtrace

      exit 1
    end

    def return_label
      "#{name}$#{@return_counter}"
    end

    def increment_return_counter
      @return_counter += 1
    end

    private

    def count_local_total
      return @count_local_total if defined? @count_local_total

      local_variable_address_indices = body[..find_end_body_index]
        .select { |line| line.match? line.match? VMTranslator::Commands::LOCAL_REGEX }
        .map { |line| line.match(VMTranslator::Commands::LOCAL_REGEX)[1].to_i }

      total = Array(local_variable_address_indices).max
      @count_local_total = total unless total.nil?
    end

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
