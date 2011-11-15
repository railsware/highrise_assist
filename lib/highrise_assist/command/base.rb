require "fileutils"

module HighriseAssist
  module Command
    class Base
      class << self
        def inherited(klass)
          Command.names.push klass.name.split("::").last.underscore
          super(klass)
        end
      end

      def initialize(options)
        @options = options.dup
        authenticate
      end

      attr_reader :options

      def run
        raise NotImplementedError, "'run' is not implemented by #{self.class.name}"
      end

      protected

      def authenticate
        require_option!(:domain, :token)

        Highrise::Base.site = "https://" + options[:domain]
        Highrise::Base.user = options[:token]
      end

      def require_option!(*names)
        names.each do |name|
          options[name].blank? and abort "#{name} option required"
        end
      end

      def log(message)
        puts message
      end

      def file_transfer
        @file_transfer ||= FileTransfer.new(options)
      end

      def download_file(*args)
        file_transfer.download(*args)
      end

      def upload_file(*args)
        file_transfer.upload(*args)
      end
    end
  end
end
