module HighriseAssist
  module Command
    class << self
      def names
        @names ||= []
      end

      def defined?(name)
        names.include?(name)
      end

      def run(name, options)
        self.const_get(name.classify).new(options).run
      end
    end
  end
end

require "highrise_assist/command/base"
require "highrise_assist/command/export"
