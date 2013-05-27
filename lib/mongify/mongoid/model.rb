require "mongify/mongoid/model/field"
require "mongify/mongoid/model/relation"

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
      def add_field(name, type, options={})
        options.stringify_keys!
        return nil if name.to_s.downcase == "id" || options['ignore'] || options['references']
        name = options['rename_to'] if options['rename_to'].present?
        @fields[name.to_sym] = Field.new(name, type, options)
      end

      # Adds a relationship definition to the class, e.g add_relationship("embedded_in", "users", {})
      def add_relation(name, association, options={})
        @relations << Mongify::Mongoid::Model::Relation.new(name.to_s, association, options)
      end

      # Get binding for ERB template
      def get_binding
        return binding()
      end

      # Improved inspection output
      def to_s
        "#<Mongify::Mongoid::Model::#{name} fields=#{@fields.keys} relations=#{@relations.map{|r| "#{r.name} :#{r.association}"}}>"
      end
    end
  end
end
