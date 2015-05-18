module Sso
  # One thing tha bugs me is when I cannot see which part of the code caused a log message.
  # This mixin will include the current class name as Logger `progname` so you can show that it in your logfiles.
  #
  module Logging
    extend ActiveSupport::Concern

    module ClassMethods
      def debug(&block)
        logger && logger.debug(progname, &block)
      end

      def info(&block)
        logger && logger.info(progname, &block)
      end

      def warn(&block)
        logger && logger.warn(progname, &block)
      end

      def error(&block)
        logger && logger.error(progname, &block)
      end

      def fatal(&block)
        logger && logger.fatal(progname, &block)
      end

      def progname
        self.to_s
      end

      def logger
        Rails.logger
      end
    end #class_methods

    def debug(&block)
      self.class.debug(&block)
    end

    def info(&block)
      self.class.info(&block)
    end

    def warn(&block)
      self.class.warn(&block)
    end

    def error(&block)
      self.class.error(&block)
    end

    def fatal(&block)
      self.class.fatal(&block)
    end
  end
end
