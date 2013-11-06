require 'zlib'

module Restforce
  # Middleware to uncompress GZIP compressed responses from Salesforce.
  class Middleware::Gzip < Restforce::Middleware
    ACCEPT_ENCODING_HEADER  = 'Accept-Encoding'.freeze
    CONTENT_ENCODING_HEADER = 'Content-Encoding'.freeze
    ENCODING                = 'gzip'.freeze

    def call(env)
      env[:request_headers][ACCEPT_ENCODING_HEADER] = ENCODING if @options[:compress]
      @app.call(env).on_complete do |environment|
        on_complete(environment)
      end
    end

    def on_complete(env)
      env[:body] = decompress(env[:body]) if gzipped?(env)
      if env[:body].is_a?(String) and (env[:body].to_s == "\"OK\"")
        env[:body] = "[{\"message\":\"You made it son\"}]"
      end
    end

    # Internal: Returns true if the response is gzipped.
    def gzipped?(env)
      env[:response_headers][CONTENT_ENCODING_HEADER] == ENCODING
    end

    # Internal: Decompresses a gzipped string.
    def decompress(body)
      Zlib::GzipReader.new(StringIO.new(body)).read
    end
  end
end
