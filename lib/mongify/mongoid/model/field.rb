module Mongify
  module Mongoid
    class Model
      #Field for a Mongoid file
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