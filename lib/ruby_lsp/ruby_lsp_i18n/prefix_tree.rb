# typed: strict
# frozen_string_literal: true

module RubyLsp
  module RubyLspI18n
    # Copy from: https://github.com/Shopify/ruby-lsp/blob/main/lib/ruby_indexer/lib/ruby_indexer/prefix_tree.rb
    # A PrefixTree is a data structure that allows searching for partial strings fast. The tree is similar to a nested
    # hash structure, where the keys are the characters of the inserted strings.
    #
    # ## Example
    # ```ruby
    # tree = PrefixTree[String].new
    # # Insert entries using the same key and value
    # tree.insert("bar", "bar")
    # tree.insert("baz", "baz")
    # # Internally, the structure is analogous to this, but using nodes:
    # # {
    # #   "b" => {
    # #     "a" => {
    # #       "r" => "bar",
    # #       "z" => "baz"
    # #     }
    # #   }
    # # }
    # # When we search it, it finds all possible values based on partial (or complete matches):
    # tree.search("") # => ["bar", "baz"]
    # tree.search("b") # => ["bar", "baz"]
    # tree.search("ba") # => ["bar", "baz"]
    # tree.search("bar") # => ["bar"]
    # ```
    #
    # A PrefixTree is useful for autocomplete, since we always want to find all alternatives while the developer hasn't
    # finished typing yet. This PrefixTree implementation allows for string keys and any arbitrary value using the
    # generic
    # `Value` type.
    #
    # See https://en.wikipedia.org/wiki/Trie for more information
    #: [Value]
    class PrefixTree
      #: -> void
      def initialize
        @root = Node.new(
          "",
          "", #: as untyped
        ) #: Node[Value]
      end

      # Search the PrefixTree based on a given `prefix`. If `foo` is an entry in the tree, then searching for `fo` will
      # return it as a result. The result is always an array of the type of value attribute to the generic `Value` type.
      # Notice that if the `Value` is an array, this method will return an array of arrays, where each entry is
      # the array
      # of values for a given match
      #: (String prefix) -> Array[Value]
      def search(prefix)
        node = find_node(prefix)
        return [] unless node

        node.collect
      end

      # Inserts a `value` using the given `key`
      #: (String key, Value value) -> void
      def insert(key, value)
        node = @root

        key.each_char do |char|
          node = node.children[char] ||= Node.new(char, value, node)
        end

        # This line is to allow a value to be overridden. When we are indexing files, we want to be able to update
        # entries for a given fully qualified name if we find more occurrences of it. Without being able to override,
        # that would not be possible
        node.value = value
        node.leaf = true
      end

      # Deletes the entry identified by `key` from the tree. Notice that a partial match will still delete all entries
      # that match it. For example, if the tree contains `foo` and we ask to delete `fo`, then `foo` will be deleted
      #: (String key) -> void
      def delete(key)
        node = find_node(key)
        return unless node

        # Remove the node from the tree and then go up the parents to remove any of them with empty children
        parent = node.parent #: Node[Value]?

        while parent
          parent.children.delete(node.key)
          return if parent.children.any? || parent.leaf

          node = parent
          parent = parent.parent
        end
      end

      private

      # Find a node that matches the given `key`
      #: (String key) -> Node[Value]?
      def find_node(key)
        node = @root

        key.each_char do |char|
          snode = node.children[char]
          return nil unless snode

          node = snode
        end

        node
      end

      #: [Value]
      class Node
        #: Hash[String, Node[Value]]
        attr_reader :children

        #: String
        attr_reader :key

        #: Value
        attr_accessor :value

        #: bool
        attr_accessor :leaf

        #: Node[Value]?
        attr_reader :parent

        #: (String key, Value value, ?Node[Value]? parent) -> void
        def initialize(key, value, parent = nil)
          @key = key
          @value = value
          @parent = parent
          @children = {} #: Hash[String, Node[Value]]
          @leaf = false #: bool
        end

        #: -> Array[Value]
        def collect
          result = []
          result << @value if @leaf

          @children.each_value do |node|
            result.concat(node.collect)
          end

          result
        end
      end
    end
  end
end
