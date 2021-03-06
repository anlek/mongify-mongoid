require "mongify/mongoid/model/field"
require "mongify/mongoid/model/relation"

module Mongify
  module Mongoid
    #
    # Class that will be used to define a mongoid model
    #
    class Model
      #default created at field name
      CREATED_AT_FIELD = 'created_at'
      #default update at field name
      UPDATED_AT_FIELD = 'updated_at'

      #List of fields to exclude from the model
      EXCLUDED_FIELDS = [
        'id',
        CREATED_AT_FIELD,
        UPDATED_AT_FIELD
      ]
      attr_accessor :class_name, :table_name, :fields, :relations, :polymorphic_as

      #Returns true if it has any timestamps
      def has_timestamps?
        has_created_at_timestamp? || has_updated_at_timestamp?
      end

      #Returns true both timestamps are present (created_at and updated_at)
      def has_both_timestamps?
        has_created_at_timestamp? && has_updated_at_timestamp?
      end

      #Returns true created_at timestamp exists
      def has_created_at_timestamp?
        !!@created_at
      end

      #Returns true updated_at timestamp exists
      def has_updated_at_timestamp?
        !!@updated_at
      end

      #Returns true it is a polymorphic model
      def polymorphic?
        !!@polymorphic_as
      end

      def initialize(options = {})
        @class_name = options[:class_name].to_s
        @table_name = options[:table_name].to_s
        self.polymorphic_as = options[:polymorphic_as]

        @fields = {}
        @relations = []
      end
      alias :name :class_name

      # Adds a field definition to the class,
      # e.g:
      #   add_field("field_name", "String", {rename_to: "name"})
      def add_field(name, type, options={})
        options.stringify_keys!
        return if options['ignore'] || options['references'] || polymorphic_field?(name)
        check_for_timestamp(name)
        return if EXCLUDED_FIELDS.include?(name.to_s.downcase)
        name = options['rename_to'] if options['rename_to'].present?
        type = options['as'] if options['as'].present?
        begin
          @fields[name.to_sym] = Field.new(name, type, options)
        rescue InvalidField => e
          raise InvalidField, "Unknown field type #{type} for #{name} in #{class_name}"
        end
      end

      # Adds a relationship definition to the class,
      # e.g:
      #   add_relation("embedded_in", "users")
      #
      # @note Embedded relations will overpower related relations
      # @return [Relation] New generated relation
      def add_relation(relation_name, association, options={})
        if existing = find_relation_by(association)
          if relation_name =~ /^embed/
            delete_relation_for association
          else
            return
          end
        end
        Relation.new(relation_name.to_s, association, options).tap do |r|
          @relations << r
        end
      end

      # Returns binding for ERB template
      # @return [Binding]
      def get_binding
        return binding()
      end

      # Returns an improved inspection output including fields and relations
      # @return [String] String representation of the model
      def to_s
        "#<Mongify::Mongoid::Model::#{name} fields=#{@fields.keys} relations=#{@relations.map{|r| "#{r.name} :#{r.association}"}}>"
      end

      #######
      private
      #######

      # Checks if given field name is a known timestamp field
      # @return [nil]
      def check_for_timestamp name
        @created_at = true if name == CREATED_AT_FIELD
        @updated_at = true if name == UPDATED_AT_FIELD
        nil
      end

      # Returns true if given field name follows polymorphic rules
      # @return [Boolean]
      def polymorphic_field? name
        return unless polymorphic?
        name == "#{polymorphic_as}_type" || name == "#{polymorphic_as}_id"
      end

      # Finds a relation by association
      # @return [Relation, nil] The found relation or nil
      def find_relation_by association
        @relations.find{|r| r.association == association || r.association == association.singularize}
      end

      # Deletes given relations based on association name
      # @return [nil]
      def delete_relation_for association
        @relations.reject!{ |r| r.association == association || r.association == association.singularize}
      end
    end
  end
end
