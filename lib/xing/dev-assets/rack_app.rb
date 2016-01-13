require 'xing/dev-assets/cookie_setter'
require 'xing/dev-assets/goto_param'
require 'xing/dev-assets/logger'
require 'xing/dev-assets/empty_file'
require 'xing/dev-assets/strip_incoming_cache_headers'

module Xing
  module DevAssets
    class RackApp
      # Should be override by client app. Ironically, override with exactly
      # this definition will usually work.
      # (because this will log into a dir in the gem, but copied into subclass
      # will be relative to that file and therefore into the project)
      def self.log_root
        File.expand_path("../../log", __FILE__)
      end

      def self.logpath_for_env(env)
        File.join( log_root, "#{env}_static.log")
      end

      def self.build(root_path, backend_port)
        backend_url = ENV["XING_BACKEND_URL"] || ENV["LRD_BACKEND_URL"] || "http://localhost:#{backend_port}/"
        env = ENV['RAILS_ENV'] || 'development'

        puts "Setting up static app:"
        puts "  serving files from #{root_path}"
        puts "  using #{backend_url} for API"
        puts "  logging to #{logpath}"

        logger = Logger.new(logpath_for_env(env))

        Rack::Builder.new do
          use GotoParam
          use CookieSetter, "lrdBackendUrl", backend_url
          use CookieSetter, "xingBackendUrl", backend_url
          use Rack::CommonLogger, logger
          use StripIncomingCacheHeaders
          if rails_env != "development"
            map "/assets/livereload.js" do
              run EmptyFile.new
            end
          end
          use Rack::Static, {
            :urls => [""],
            :root => root_path,
            :index => "index.html",
            :header_rules => {
              :all => {"Cache-Control" => "no-cache, max-age=0" } #no caching development assets
            }
          }
          run proc{ [500, {}, ["Something went wrong"]] }
        end
      end
    end
  end
end
