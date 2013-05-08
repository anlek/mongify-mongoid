module Mongify
  module Mongoid
    module CLI
      module Command
        #
        # A command to run the different commands in the application (related to Mongifying).
        #
        class Worker
          attr_accessor :view
          
          
          def initialize(translation_file=nil, output_dir=nil, options={})
            @translation_file = translation_file
            @output_dir = output_dir
            @options = options
          end
          
          #Executes the worked based on a given command
          def execute(view)
            self.view = view
            
            raise TranslationFileNotFound, "Translation file is required" unless @translation_file
            raise TranslationFileNotFound, "Unable to find Translation File #{@translation_file}" unless File.exists?(@translation_file)
          
            #TODO: Check if output exists

            raise OverwritingFolder, "Output folder (#{output_folder}) already exists, for your safety we can't continue, pass -f to overwrite" if File.exists?(output_folder) && !@options[:overwrite]

            Mongify::Mongoid::Generator.new(@translation_file, output_folder).process
            
            view.report_success
          end
          
          # Passes find command to parent class
          
          #######
          private
          #######

          def output_folder
            @output_dir = Dir.pwd if @output_dir.nil?
            @output_dir
          end
          
        end
      end
    end
  end
end
