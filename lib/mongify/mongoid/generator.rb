module Mongify
  module Mongoid
    #
    # Generator - Processes translation file and generates output based on models
    #
    class Generator
      attr_reader :models
      def initialize(translation_file, output_dir)
        @translation_file = translation_file
        @output_dir = output_dir
        @models = {}
      end

      # Process translation file and generate output files
      # @return [nil]
      def process
        unless File.exists?(@translation_file)
          raise Mongify::Mongoid::TranslationFileNotFound, "Unable to find Translation File at #{@translation_file}"
        end

        generate_models
        process_fields
        generate_embedded_relations
        write_models_to_file
        nil
      end

      # Generate models based on traslation tables
      # @return [Array] List of tables that models were generated from
      def generate_models
        (translation.tables + translation.polymorphic_tables).each do |table|
          build_model(table)
        end
      end

      # Goes through all the models and adds fields based on columns in the given table
      # @return [Array] List of models that fields were added to
      def process_fields
        models.each do |key, model|
          table = translation.find(model.table_name)
          model = generate_fields_for model, table if table
        end
      end

      # Goes through embedded relationships
      # @return [Array] List of tables that were used to extra embedded relations
      def generate_embedded_relations
        translation.embed_tables.each do |table|
          extract_embedded_relations(table)
        end
      end

      # Writes models to files
      # @return [Printer] Printer class used to write output
      def write_models_to_file
        Printer.new(models, @output_dir).tap do |p|
          p.write
        end
      end

      # Returns model based on table name
      # @param [String] name Name of table
      # @return [Model, nil] Found model or nil
      def find_model(name)
        @models[name.to_s.downcase.to_sym]
      end

      # Returns Mongify translation class for given translation file
      # @return [Mongify::Translation] Translation file
      def translation
        @translation ||= Mongify::Translation.parse(@translation_file)
      end

      #######
      private
      #######
      
      # Generates fields for given model and it's table
      # @param [Model] model
      # @param [Mongify::Database::Table] table
      # @return [Array] List of columns from the table
      def generate_fields_for(model, table)
        table.columns.each do |column|
          if column.options['references'] && parent_model = find_model(column.options['references'])
            model.add_relation(Model::Relation::BELONGS_TO, parent_model.class_name.downcase)
            #TODO: Look into if there is there a way to figure out a has_one relationship?
            parent_model.add_relation(Model::Relation::HAS_MANY, model.table_name)
          else
            model.add_field(column.name, column.type.to_s.classify, column.options)
          end
        end
      end

      # Extracts embedded relationships for given table
      # @param [Mongify::Database::Table] table
      # @return [Model] Model for the given table
      def extract_embedded_relations(table)
        model = find_model(table.name)
        parent_model = find_model(table.embed_in)

        model.add_relation(Model::Relation::EMBEDDED_IN, table.embed_in)
        parent_model.add_relation((table.embedded_as_object? ? Model::Relation::EMBEDS_ONE : Model::Relation::EMBEDS_MANY), model.table_name)
        model
      end

      # Returns build model based on a table
      # @param [Mongify::Database::Table] table
      def build_model(table)
        model = Mongify::Mongoid::Model.new(class_name: table.name.classify, table_name: table.name)
        model.polymorphic_as = table.polymorphic_as if table.polymorphic?
        #TODO: Might need to check that model doesn't already exist in @models
        @models[table.name.downcase.to_sym] = model
        model
      end
    end
  end
end
