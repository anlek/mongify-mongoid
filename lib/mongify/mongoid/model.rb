module Mongify
  module Mongoid
    # Class that will be used to define a mongoid model
    class Model
      attr_accessor :class_name, :table_name, :fields, :relations

      def initialize(options = {})
        @class_name = options[:class_name].to_s
        @table_name = options[:table_name].to_s

        @fields = {}
        @relations = []
      end
      alias :name :class_name

      # Adds a field definition to the class, e.g add_field("field_name", "String")
      def add_field(name, type)
        @fields[name] = type
      end

      # Adds a relationship definition to the class, e.g add_relationship("embedded_in", "users", {})
      def add_relation(name, association, options ={})
        @relations << Mongify::Mongoid::Relation.new(name.to_s, association, options)
      end
    end
  end
end
