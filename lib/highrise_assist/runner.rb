require "optparse"

module HighriseAssist
  class Runner
    def self.run(*args)
      new(*args).run!
    end

    def initialize(argv)
      $KCODE = 'u'

      @argv = argv
      @options = {}
      @options[:skip_items] = []
    end

    def run!
      parser = OptionParser.new do |o|
        o.banner = "Usage: #{$0} COMMAND [options]"

        o.separator ""
        o.separator "Commands:"
        o.separator "  * export - export next highrise items:"
        %w(cases deals people companies emails notes comments attachments).each do |item|
          o.separator "    * #{item}"
        end

        o.separator ""
        o.separator "Common options:"
        o.on("--domain DOMAIN", "highrise subdomain or full domain name") { |v| set_domain_option(v) }
        o.on("--token TOKEN", "highrise API authentication token") { |v| @options[:token] = v }
        o.separator ""

        o.separator "Export options:"
        o.on("--tag TAG", "filter items with given tag name") { |v| @options[:tag] = v }
        o.on("--directory DIRECTORY", "working directory") { |v| @options[:directory] = v }
        o.on("--format FORMAT", "data format (#{Command::Export::FORMATS.join(',')}) ") { |v| @options[:format] = v }
        o.on("--skip-attachments", "don't download attachments") { @options[:skip_attachments] = true }
        o.on("--skip-cases", "don't export cases") { @options[:skip_items] << "Kase" }
        o.on("--skip-deals", "don't export deals") { @options[:skip_items] << "Deal" }
        o.on("--skip-notes", "don't export notes") { @options[:skip_items] << "Note" }
        o.on("--skip-emails", "don't export emails") { @options[:skip_items] << "Email" }
        o.on("--skip-comments", "don't export comments") { @options[:skip_items] << "Comment" }

        o.separator ""
        o.separator "Misc options:"
        o.on_tail("-h", "--help", "Show this message") { puts o; exit }
        o.on_tail('-v', '--version', "Show version")   { puts HighriseAssist::VERSION; exit }
      end

      parser.parse!(@argv)

      command = @argv.first

      Command.defined?(command) or raise OptionParser::ParseError, "Unknown command #{command.inspect}"

      Command.run(command, @options)
    rescue OptionParser::ParseError
      warn e.message
      puts parser.help
      exit 1
    end

    private

    def set_domain_option(value)
      @options[:domain] = value.include?('.') ? value : "#{value}.highrisehq.com"
    end

  end
end
