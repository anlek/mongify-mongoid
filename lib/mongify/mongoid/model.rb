require "mongify/mongoid/model/field"
require "mongify/mongoid/model/relation"

module Mongify
  module Mongoid
    # Class that will be used to define a mongoid model
    class Model
      CREATED_AT_FIELD = 'created_at'
      UPDATED_AT_FIELD = 'updated_at'
      EXCLUDED_FIELDS = [
        'id',
        CREATED_AT_FIELD,
        UPDATED_AT_FIELD
      ]
      attr_accessor :class_name, :table_name, :fields, :relations, :polymorphic_as

      def has_timestamps?
        has_created_at_timestamp? || has_updated_at_timestamp?
      end
      def has_both_timestamps?
        has_created_at_timestamp? && has_updated_at_timestamp?
      end
      def has_created_at_timestamp?
        !!@created_at
      end
      def has_updated_at_timestamp?
        !!@updated_at
      end

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

      # Adds a field definition to the class, e.g add_field("field_name", "String")
      def add_field(name, type, options={})
        options.stringify_keys!
        check_for_timestamp(name)
        return if EXCLUDED_FIELDS.include?(name.to_s.downcase) || options['ignore'] || options['references'] || polymorphic_field?(name)
        name = options['rename_to'] if options['rename_to'].present?
        @fields[name.to_sym] = Field.new(name, type, options)
      end

      # Adds a relationship definition to the class, e.g add_relation("embedded_in", "users", {})
      #   Note: Embedded relationships will overpower related relationship
      def add_relation(relation_name, association, options={})
        if existing = find_relation_by(association)
          if relation_name =~ /^embed/
            delete_relation_for association
          else
            return
          end
        end
        @relations << Relation.new(relation_name.to_s, association, options)
      end

      # Get binding for ERB template
      def get_binding
        return binding()
      end

      # Improved inspection output
      def to_s
        "#<Mongify::Mongoid::Model::#{name} fields=#{@fields.keys} relations=#{@relations.map{|r| "#{r.name} :#{r.association}"}}>"
      end

      def clear_relations
        @relations = []
      end

      #######
      private
      #######
      
      def check_for_timestamp name
        @created_at = true if name == CREATED_AT_FIELD
        @updated_at = true if name == UPDATED_AT_FIELD
      end

      def polymorphic_field? name
        name == "#{polymorphic_as}_type" || name == "#{polymorphic_as}_id"
      end

      # find a relations by association
      def find_relation_by association
        @relations.find{|r| r.association == association || r.association == association.singularize}
      end

      def delete_relation_for association
        @relations.reject!{ |r| r.association == association || r.association == association.singularize}
      end
    end
  end
end
