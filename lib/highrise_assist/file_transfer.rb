require "net/http/persistent"

module HighriseAssist
  class FileTransfer
    def initialize(options)
      @options = options

      @http = Net::HTTP::Persistent.new('highrise-file-transfer')
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @http
    end

    def download(from, to)
      uri = URI.parse(from)

      get_request = Net::HTTP::Get.new(uri.request_uri)
      get_request.basic_auth @options[:token], ''

      @http.request(uri, get_request) do |response|
        open(to, 'w') do |io|
          response.read_body { |chunk| io.write chunk }
        end
      end
    end

    def upload(from, to)
      raise NotImplementedError
    end
  end
end
