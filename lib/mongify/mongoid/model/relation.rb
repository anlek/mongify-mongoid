module Mongify
  module Mongoid
    class Model
      #
      # This class defines a relation for an association on a mongoid model
      # 
      class Relation
        # Embeds one relation name
        EMBEDS_ONE = "embeds_one"
        # Embeds many relation name
        EMBEDS_MANY = "embeds_many"
        # Embedded in relation name
        EMBEDDED_IN = "embedded_in"
        # Has one relation name
        HAS_ONE = "has_one"
        # Has many relation name
        HAS_MANY = "has_many"
        # Has and belongs to many relation name
        HAS_AND_BELONGS_TO_MANY = "has_and_belongs_to_many"
        # Belongs to relation name
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
        
        # Valid Option key values
        # currently not used
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
