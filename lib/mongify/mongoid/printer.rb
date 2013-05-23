require 'erb'

module Mongify
  module Mongoid
    # Class that writes the models to files
    class Printer
      TEMPLATE_FILE = File.expand_path('templates/mongoid.rb.erb', File.dirname(__FILE__))
      attr_accessor :models, :output_directory
      def initialize(models, output_directory)
        @models = models
        @output_directory = output_directory
      end

      def write
        models.each do |key, model|
          write_file(model)
        end
      end

      #######
      private
      #######
      
      def template
        @template ||= File.read(TEMPLATE_FILE)
      end
      
      def write_file model
        output = render_file model
        save_file output, model.name
      end

      def render_file model
        ERB.new(template, nil, '-').result(model.get_binding)
      end

      def save_file output, file_name
        File.open(File.join(output_directory, "#{file_name.downcase}.rb"), 'w') {|f| f.write(output) }
      end
    end
  end
end