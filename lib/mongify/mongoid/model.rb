module Mongify
  module Mongoid
    # Class that will be used to define a mongoid model
    class Model
      # Holds a list of all relations for a class
      RELATIONSHIPS = %w(embeds_one embeds_many embedded_in has_one has_many has_and_belongs_to_many belongs_to)

      attr_accessor :fields, :relationships, :name

      def initialize(name)
        @name = name.classify

        @fields = {}
        @relationships = Hash.new { |h,k| h[k] = [] }
      end

      # Adds a field definition to the class, e.g add_field("field_name", "String")
      def add_field(name, type)
        @fields[name] = type
      end

      RELATIONSHIPS.each do |relation|

        # Adds a mongoid relationship to the class
        define_method "add_#{relation}_relation" do |associated|
          @relationships[relation] << associated
          associated
        end
      end
    end
  end
end
