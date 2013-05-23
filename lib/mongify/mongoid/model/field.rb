module Mongify
  module Mongoid
    class Model
      #Field for a Mongoid file
      #
      #TODO: Add approved types
      #TODO: Catch Boolean and morph it into Mongoid's Boolean
      class Field
        attr_accessor :name, :type, :options
        def initialize(name, type, options={})
          @name = name
          @type = type
          @options = options
        end
      end
    end
  end
end