module Mongify
  module Mongoid
    class Model
      # This class defines a relation for an association on a mongoid model
      class Relation
        EMBEDS_ONE = "embeds_one"
        EMBEDS_MANY = "embeds_many"
        EMBEDDED_IN = "embedded_in"
        HAS_ONE = "has_one"
        HAS_MANY = "has_many"
        HAS_AND_BELONGS_TO_MANY = "has_and_belongs_to_many"
        BELONGS_TO = "belongs_to"

        # Holds a list of all allowed relations
        VALID_RELATIONS = [
          EMBEDS_ONE,
          EMBEDS_MANY,
          EMBEDDED_IN,
          HAS_ONE,
          HAS_MANY,
          HAS_AND_BELONGS_TO_MANY,
          BELONGS_TO
        ]

        # List of fields that need to be singularized
        SINGULARIZE_RELATIONS = [
          BELONGS_TO,
          EMBEDDED_IN,
          EMBEDS_ONE
        ]

        OPTION_KEYS = %w(class_name inverse_of)

        attr_accessor :name, :association, :options

        def initialize(name, association, options = {})
          @name, @association, @options =  name.to_s, association.to_s, options
          unless VALID_RELATIONS.include?(@name)
            raise Mongify::Mongoid::InvalidRelation, "Mongoid does not support the relation #{name} for model associations"
          end

          #Singularize association if belongs_to or embedded_in
          self.association = association.singularize if SINGULARIZE_RELATIONS.include? name 
          
        end
      end
    end
  end
end
