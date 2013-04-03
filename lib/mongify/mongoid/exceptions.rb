module Mongify
  module Mongoid
    # Base Mongify Error
    class Error < RuntimeError; end

    # Not Implemented Error from Mongify
    class NotImplementedError < Error; end
    
    # File Not Found Exception
    class FileNotFound < Error; end
    # Raised when Translation file is missing
    class TranslationFileNotFound < FileNotFound; end
    
    
    # Raised when application has no root folder set
    class RootMissing < Error; end
    
    # Raised when an invalid option is passed via CLI
    class InvalidOption < Error; end
  end
end