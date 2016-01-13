module Xing
  module DevAssets
    class Dumper
      def initialize(app)
        require 'pp'
        @app = app
      end

      def call(env)
        res = @app.call(env)
        pp env
        pp res
        return res
      end
    end
  end
end
