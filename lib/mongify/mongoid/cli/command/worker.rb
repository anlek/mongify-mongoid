module Mongify
  module Mongoid
    module CLI
      module Command
        #
        # A command to run the different commands in the application (related to Mongifying).
        #
        class Worker
          attr_accessor :view
          
          
          def initialize(translation_file=nil, output_dir=nil, parser="")
            @translation_file = translation_file
            @output_dir = output_dir
            @parser = parser
          end
          
          #Executes the worked based on a given command
          def execute(view)
            self.view = view
            
            raise TranslationFileNotFound, "Translation file is required" unless @translation_file
            raise TranslationFileNotFound, "Unable to find Translation File at #{@translation_file}" unless File.exists?(@translation_file)
          
            #TODO: Check if output exists

            view.output("Mongify::Mongoid::Worker => SHOULD RUN SOMETHING")

            #TODO call main command 
           
            view.report_success
          end
          
          # Passes find command to parent class
          
          #######
          private
          #######

          
        end
      end
    end
  end
end
