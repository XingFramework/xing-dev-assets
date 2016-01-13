module Xing
  module DevAssets
    class CookieSetter
      def initialize(app, name, value)
        @name = name
        @value = value
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        headers["Set-Cookie"] = [(headers["Set-Cookie"]), "#@name=#@value"].compact.join("\n") unless @name.nil? or @value.nil?
        [ status, headers, body ]
      end
    end
  end
end
