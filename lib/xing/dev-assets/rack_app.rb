require 'xing/dev-assets/cookie_setter'
require 'xing/dev-assets/goto_param'
require 'xing/dev-assets/logger'
require 'xing/dev-assets/empty_file'
require 'xing/dev-assets/strip_incoming_cache_headers'

module Xing
  module DevAssets
    class RackApp
      def self.build(root_path, backend_port)
        rack_app = new
        rack_app.root_path = root_path
        rack_app.backend_port = backend_port
        yield rack_app if block_given?
        rack_app.build
      end

      attr_accessor :root_path, :backend_port, :builder
      attr_writer :builder, :backend_url, :env, :logger, :out_stream

      # Should be override by client app. Ironically, override with exactly
      # this definition will usually work.
      # (because this will log into a dir in the gem, but copied into subclass
      # will be relative to that file and therefore into the project)
      def log_root
        File.expand_path("../../log", __FILE__)
      end

      def logpath_for_env
        File.join( log_root, "#{env}_static.log")
      end

      def out_stream
        @out_stream ||= $stdout
      end

      def backend_url
        @backend_url ||= ENV["XING_BACKEND_URL"] || ENV["LRD_BACKEND_URL"] || "http://localhost:#{backend_port}/"
      end

      def env
        @env ||= ENV['RAILS_ENV'] || 'development'
      end

      def logger
        @logger ||= Logger.new(logpath_for_env)
      end

      def report_startup
        out_stream.puts "Setting up static app:"
        out_stream.puts "  serving files from #{root_path}"
        out_stream.puts "  using #{backend_url} for API"
        out_stream.puts "  logging to #{logpath_for_env}"
      end

      def goto_redirect
        builder.use GotoParam
      end

      def cookies
        builder.use CookieSetter, "lrdBackendUrl", backend_url
        builder.use CookieSetter, "xingBackendUrl", backend_url
      end

      def disable_caching
        builder.use StripIncomingCacheHeaders
      end

      def logging
        builder.use Rack::CommonLogger, logger
      end

      def shortcut_livereload
        if env != "development"
          builder.map "/assets/livereload.js" do
            run EmptyFile.new
          end
        end
      end

      def static_assets
        builder.use Rack::Static, {
          :urls => [""],
          :root => root_path,
          :index => "index.html",
          :header_rules => {
            :all => {"Cache-Control" => "no-cache, max-age=0" } #no caching development assets
          }
        }
      end

      def stub_application
        builder.run proc{ [500, {}, ["Something went wrong"]] }
      end

      def setup_middleware
        goto_redirect
        cookies
        disable_caching
        logging
        shortcut_livereload
        static_assets
      end

      def builder
        @builder ||= Rack::Builder.new
      end

      def build
        report_startup

        setup_middleware
        stub_application

        builder
      end
    end
  end
end
