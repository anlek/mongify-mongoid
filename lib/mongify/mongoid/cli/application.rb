module Mongify
  module Mongoid
   # The Command Line Interface module
    module CLI
      #
      # Represents an instance of a Mongify Mongoid application.
      # This is the entry point for all invocations of Mongify from the
      # command line.
      #
      class Application

        # Successful execution exit code
        STATUS_SUCCESS = 0
        # Failed execution exit code
        STATUS_ERROR   = 1

        def initialize(arguments=[], stdin=$stdin, stdout=$stdout)
          arguments = ['-h'] if arguments.empty?
          @options = Options.new(arguments)
          @status = STATUS_SUCCESS
        end

        # Runs the application
        def execute!
          begin
            cmd = @options.parse
            return cmd.execute(self)
          rescue Error => error
            $stderr.puts "ERROR: \n#{error}"
            $stderr.puts "\nIf this is an issue that you can not figure out, feel free to submit an issue report at:"
            $stderr.puts "https://github.com/anlek/mongify-mongoid/issues"
            report_error
          rescue Exception => error
            $stderr.puts "UNKNOWN ERROR: \n#{error}"
            $stderr.puts "\nWe are not sure what happen but feel free to submit this issue report at:"
            $stderr.puts "https://github.com/anlek/mongify-mongoid/issues"
            $stderr.puts ""
            report_error
            raise error
          end
        end

        # Sends output to the UI
        def output(message)
          UI.puts(message)
        end

        # Sets status code as successful
        def report_success
          @status = STATUS_SUCCESS
        end

        # Sets status code as failure (or error)
        def report_error
          @status = STATUS_ERROR
        end
      end
    end
  end
end