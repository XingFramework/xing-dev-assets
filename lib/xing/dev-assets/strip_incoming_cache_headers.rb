module Xing
  module DevAssets
    class StripIncomingCacheHeaders
      def initialize(app)
        @app = app
      end

      def call(env)
        env.delete('HTTP_IF_MODIFIED_SINCE')
        @app.call(env)
      end
    end
  end
end
