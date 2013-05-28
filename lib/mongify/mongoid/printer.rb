require 'erb'

module Mongify
  module Mongoid
    # Class that writes the models to individule mongoid model files
    class Printer
      TEMPLATE_FILE = File.expand_path('templates/mongoid.rb.erb', File.dirname(__FILE__))
      attr_accessor :models, :output_directory
      def initialize(models, output_directory)
        @models = models
        @output_directory = output_directory
      end

      # Writes models to given output directory
      def write
        models.each do |key, model|
          write_file(model)
        end
      end

      #######
      private
      #######
      
      # Returns ERB template file
      def template
        @template ||= File.read(TEMPLATE_FILE)
      end
      
      # Writes given model to output file
      def write_file model
        output = render_file model
        save_file output, model.name
      end

      # Renders ERB template for given model
      def render_file model
        ERB.new(template, nil, '-').result(model.get_binding)
      end

      # Saveds text output into a file (output_directory/model_name.rb)
      def save_file output, file_name
        File.open(File.join(output_directory, "#{file_name.downcase}.rb"), 'w') {|f| f.write(output) }
      end
    end
  end
end