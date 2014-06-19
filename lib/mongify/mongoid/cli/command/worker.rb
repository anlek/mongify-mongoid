require 'fileutils'
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

            valid_translation? @translation_file
            prevent_overwrite! (@options)

            unless File.directory?(output_folder)
               FileUtils.mkdir_p(output_folder)
            end

            generator = Mongify::Mongoid::Generator.new(@translation_file, output_folder)
            generator.process

            output_success_message

            view.report_success
          end

          #Folder location of the output
          def output_folder
            @output_dir = File.join(Dir.pwd, "models") if @output_dir.nil?
            @output_dir
          end

          #######
          private
          #######

          #Verify tranlsation file exists
          def valid_translation? translation_file
            raise TranslationFileNotFound, "Translation file is required" unless translation_file
            raise TranslationFileNotFound, "Unable to find Translation File #{translation_file}" unless File.exists?(translation_file)
          end

          def prevent_overwrite! options={}
            raise OverwritingFolder, "Output folder (#{output_folder}) already exists, for your safety we can't continue, pass -f force an overwrite" if File.exists?(output_folder) && !options[:overwrite]
          end

          def output_success_message
            view.output("\nSuccessfully processed #{generator.models.count} models")
            view.output("You can find your files in #{output_folder}")
            view.output("\nThank you for using Mongify and Mongify-Mongoid!")
            view.output("If you have any issues, please feel free to report them at:\nhttps://github.com/anlek/mongify-mongoid/issues")
            view.output("")
          end



        end
      end
    end
  end
end
