module Mongify
  module Mongoid
    class Generator
      attr_reader :models
      def initialize(translation_file, output_dir)
        @translation_file = translation_file
        @output_dir = output_dir
        @models = {}
      end

      def process
        unless File.exists?(@translation_file)
          raise Mongify::Mongoid::TranslationFileNotFound, "Unable to find Translation File at #{@translation_file}"
        end

        generate_models
        process_fields
        generate_embedded_relations
        write_models_to_file
      end

      def generate_models
        translation.tables.each do |table|
          build_model(table)
        end
      end

      def process_fields
        models.each do |key, model|
          table = translation.find(model.table_name)
          model = generate_fields_for model, table if table
        end
      end

      def generate_embedded_relations
        translation.embed_tables.each do |table|
          extract_embedded_relations(table)
        end
      end

      def write_models_to_file
        Printer.new(models, @output_dir).write
      end

      def find_model(name)
        @models[name.to_s.downcase.to_sym]
      end

      #######
      private
      #######
      
      def translation
        @translation ||= Mongify::Translation.parse(@translation_file)
      end

      def generate_fields_for(model, table)
        table.columns.each do |column|
          model.add_field(column.name, column.type.to_s.classify, column.options)
        end
      end

      def extract_embedded_relations(table)
        model = find_model(table.name)
        parent_model = find_model(table.embed_in)

        model.add_relation(:embedded_in, table.embed_in)
        if table.embedded_as_object?
          parent_model.add_relation(:embeds_one, model.table_name.singularize)
        else
          parent_model.add_relation(:embeds_many, model.table_name)
        end
        model
      end


      def build_model(table)
        model = Mongify::Mongoid::Model.new(:class_name => table.name.classify, :table_name => table.name)
        #TODO: Might need to check that model doesn't already exist in @models
        @models[table.name.downcase.to_sym] = model
        model
      end


    end
  end
end
