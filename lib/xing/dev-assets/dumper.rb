module Xing
  module DevAssets
    class Dumper
      def initialize(app, log_target)
        require 'pp'
        @app = app
        @log_target = log_target
      end

      def call(env)
        @log_target.debug{ wrap("REQUEST", env.pretty_inspect)}
        res = @app.call(env)
        @log_target.debug{ wrap("RESPONSE", res.pretty_inspect) }
        return res
      end

      def wrap(thing, text)
        ["#{thing} start", text.lines.map{|ln| "  "+ln}.join("").chomp, "#{thing} end"].join("\n") + "\n"
      end
    end
  end
end
