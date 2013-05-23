module Mongify
  module Mongoid
    class Generator
      attr_reader :models
      def initialize(translation_file, output_dir=nil)
        @translation_file = translation_file
        @output_dir = output_dir
        @models = {}
      end

      def process
        unless File.exists?(@translation_file)
          raise Mongify::Mongoid::TranslationFileNotFound, "Unable to find Translation File at #{@translation_file}"
        end

        generate_root_models
        generate_embedded_models
        generate_polymorphic_models
        write_models_to_file
      end

      def generate_root_models
        translation.copy_tables.each do |table|
          generate_root_model(table)
        end
      end

      def generate_embedded_models
        translation.embed_tables.each do |table|
          generate_embedded_model(table)
        end
      end

      def generate_polymorphic_models
        translation.polymorphic_tables.each do |table|
          generate_polymorphic_model(table)
        end
      end

      def write_models_to_file
        @models.each do |model|
          write_model_to_file(model)
        end
      end

      #######
      private
      #######
      
      def translation
        @translation ||= Mongify::Translation.parse(@translation_file)
      end

      def generate_root_model(table)
        model = build_model(table)

        table.columns.each do |column|
          model.add_field(column.name, column.type.to_s.classify)
        end
      end

      def generate_embedded_model(table)
        model = build_model(table)
        parent_model = @models[table.embed_in.to_sym]

        model.add_relation(:embedded_in, table.embed_in)
        if table.embedded_as_object?
          parent_model.add_relation(:embeds_one, model.table_name)
        else
          parent_model.add_relation(:embeds_many, model.table_name)
        end
        model
      end

      def generate_polymorphic_model(table)
        model = build_model(table)
        # Do Stuff
      end

      def build_model(table)
        model = Mongify::Mongoid::Model.new(:class_name => table.name.classify, :table_name => table.name)
        #TODO: Might need to check that model doesn't already exist in @models
        @models[table.name.downcase.to_sym] = model
        model
      end

      def write_model_to_file(model)
        file_name = %[#{model.name.downcase}.rb]


        # Do Stuff

        # create_file %[#{@output_dir}/#{file_name}], <<-FILE.gsub(/^ {10}/, '')
        #   class #{model.name}
        #     #{ model.fields.map{ |field|
        #       <<-FIELD
        #         field :#{field.key}, type: #{field.value}
        #       FIELD
        #     }}
        #   end
        # FILE
      end

      def create_file(destination, content)
        FileUtils.mkdir_p(File.dirname(destination))
        File.open(destination, 'wb') { |f| f.write content }
      end
    end
  end
end
