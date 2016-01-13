module Xing
  module DevAssets
    class GotoParam
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        default = [ status, headers, body ]
        request_path = env["SCRIPT_NAME"] + env["PATH_INFO"]
        if env["QUERY_STRING"]
          request_path += "&#{env["QUERY_STRING"]}"
        end

        return default unless status == 404
        return default if /\A(assets|fonts|system)/ =~ request_path
        return default if /\.(xml|html|ico|txt)\z/ =~ request_path
        return default if /goto=/ =~ env["QUERY_STRING"]

        return [ 301, headers.merge("Location" => "/?goto=#{request_path}", "Content-Length" => "0"), [] ]
      rescue => ex
        require 'pp'
        pp ex
      end
    end
  end
end
