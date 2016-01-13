module Xing
  module DevAssets
    class EmptyFile
      BLANKNESS = [ 200, {"Content-Length" => "0"}, [""]].freeze

      def call(env)
        return BLANKNESS
      end
    end
  end
end
