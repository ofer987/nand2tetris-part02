# frozen_string_literal: true

module JackCompiler
  class MemoryScope
    attr_accessor :memory_hash, :next_scope

    def key?(name)
      return true if memory_hash.include? name
      return true if next_scope&.key? name

      false
    end

    def <<(memory_node)
      return if key? memory_node&.name

      next_index = kind_size(memory_node.kind)
      memory_node.index = next_index

      memory_hash[memory_node.name] = memory_node
    end

    def [](name)
      return memory_hash[name] if memory_hash.include? name
      return next_scope&.[](name) if next_scope&.key? name

      raise ArgumentError, "memory '#{name}' does not exist"
    end

    def local_size
      kind_size(Memory::Kind::LOCAL)
    end

    def field_memory
      results = {}
      scope = self

      until scope.nil?
        hash = scope.memory_hash
        hash.each do |name, memory|
          next unless memory.kind == Memory::Kind::FIELD

          results[name] = memory
        end

        scope = scope.next_scope
      end

      results
    end

    def field_size
      kind_size(Memory::Kind::FIELD)
    end

    def initialize(memory_hash, next_scope = nil)
      @memory_hash = memory_hash
      @next_scope = next_scope
    end

    def kind_size(kind)
      current_scope_size = memory_hash
        .select { |_key, value| value.kind == kind }
        .size

      current_scope_size + (next_scope&.kind_size(kind) || 0)
    end
  end
end
