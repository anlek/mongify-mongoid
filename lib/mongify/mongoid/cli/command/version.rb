module Mongify
  module Mongoid
    module CLI
      module Command
        #
        # A command to report the application's current version number.
        #
        class Version
          def initialize(progname)
            @progname = progname
          end
          #Executes version command
          def execute(view)
            view.output("#{@progname} #{Mongify::Mongoid::VERSION}\n")
            view.report_success
          end
        end
      end
    end
  end
end
