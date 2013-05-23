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
        Printer.new(models, @output_dir).write
      end

      #######
      private
      #######
      
      def translation
        @translation ||= Mongify::Translation.parse(@translation_file)
      end

      def generate_root_model(table)
        model = build_model(table)

        #TODO: Need to run this in it's own call because "has_many" and "belongs_to" will be able to get derived, however all tables must be mapped
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
        #TODO: Finish this
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
