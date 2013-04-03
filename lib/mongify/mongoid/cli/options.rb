require 'optparse'
module Mongify
  module Mongoid
    module CLI
      #
      # Used to parse the options for an application
      #
      class Options
        def initialize(argv)
          @parsed = false
          @argv = argv
          @parser = OptionParser.new
          set_options
          parse_options
        end

        # Banner for help output
        def banner
          progname = @parser.program_name
          return <<EOB
  Usage: #{progname} translation_file.rb [--output ~/output_dir]

  Examples:
  #{progname} database_translation.rb
  #{progname} database_translation.rb -O ~/output_dir
  #{progname} process database.config database_translation.rb

  See http://github.com/anlek/mongify for more details

EOB
        end

        # Sets the options for CLI
        # Also used for help output
        def set_options
          @parser.banner = banner
          @parser.separator "Common options:"
          @parser.on("-h", "--help", "Show this message") do
            @command_class = Command::Help
          end
          @parser.on("-v", "--version", "Show version") do
            @command_class = Command::Version
          end
          @parser.on("-O", "--output DIR", "Output Directory") do |dir|
            @output_dir = dir
          end
        end

        # Parses CLI passed attributes and figures out what command user is trying to run
        def parse
          case 
            when @command_class == Command::Help
              Command::Help.new(@parser)
            when @command_class == Command::Version
              Command::Version.new(@parser.program_name)
            else
              Command::Worker.new(translation_file, output_dir, @parser)
          end
        end

        #######
        private
        #######

        # Returns the translation_file or nil
        def translation_file(argv=@argv)
          argv[0] if argv.length >= 1
        end

        # Returns the config file
        def output_dir(argv=@argv)
          @output_dir if @output_dir && File.exist?(@output_dir) && File.directory?(@output_dir)
        end

        # option parser, ensuring parse_options is only called once
        def parse_options
          @parser.parse!(@argv)
        rescue OptionParser::InvalidOption => er
          raise Mongify::InvalidOption, er.message, er.backtrace
        end
      end
    end
  end
end