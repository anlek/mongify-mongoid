module Mongify
  module Mongoid
    class Model
      # This class defines a relation for an association on a mongoid model
      class Relation
        # Holds a list of all allowed relations
        VALID_RELATIONS = %w(embeds_one embeds_many embedded_in has_one has_many has_and_belongs_to_many belongs_to)

        OPTION_KEYS = %w(class_name inverse_of)

        attr_accessor :name, :association, :options

        def initialize(name, association, options = {})
          @name, @association, @options =  name.to_s, association.to_s, options
          unless VALID_RELATIONS.include?(@name)
            raise Mongify::Mongoid::InvalidRelation, "Mongoid does not support the relation #{name} for model associations"
          end

          
        end
      end
    end
  end
end
