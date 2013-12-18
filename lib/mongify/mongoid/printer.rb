require 'erb'

module Mongify
  module Mongoid
    #
    # Class that writes the models to individule mongoid model files
    # 
    class Printer
      #Template file location
      TEMPLATE_FILE = File.expand_path('templates/mongoid.rb.erb', File.dirname(__FILE__))
      attr_accessor :models, :output_directory
      def initialize(models, output_directory)
        @models = models
        @output_directory = output_directory
      end

      # Writes models to given output directory
      # @return [nil]
      def write
        models.each do |key, model|
          write_file(model)
        end
        nil
      end

      #######
      private
      #######
      
      # Returns ERB template file
      # @return [String] Template file content
      def template
        @template ||= File.read(TEMPLATE_FILE)
      end
      
      # Writes given model to output file
      # @param [Model] model Model
      # @return [String] The written output
      def write_file model
        output = render_file model
        save_file output, model.name.underscore
        output
      end

      # Renders ERB template for given model
      # @return [String] rendered template string
      def render_file model
        ERB.new(template, nil, '-').result(model.get_binding)
      end

      # Saveds text output into a file (output_directory/model_name.rb)
      # @return [File] saved file
      def save_file output, file_name
        File.open(File.join(output_directory, "#{file_name.downcase}.rb"), 'w') {|f| f.write(output) }
      end
    end
  end
end
