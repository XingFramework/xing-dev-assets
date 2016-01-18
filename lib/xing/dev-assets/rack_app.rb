require 'xing/dev-assets/cookie_setter'
require 'xing/dev-assets/goto_param'
require 'xing/dev-assets/logger'
require 'xing/dev-assets/dumper'
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
        @log_root ||= File.expand_path("../../log", __FILE__)
      end
      attr_writer :log_root

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

      def log_level
        @log_level ||= Logger::WARN
      end

      LEVEL_LOOKUP = {
        :debug => Logger::DEBUG,
        :info => Logger::INFO,
        :warn => Logger::WARN,
        :error => Logger::ERROR,
        :fatal => Logger::FATAL,
        :unknown => Logger::UNKNOWN
      }.freeze
      def log_level=(value)
        @log_level =
          case value
          when Symbol
            LEVEL_LOOKUP.fetch(value)
          when *LEVEL_LOOKUP.values
            value
          else
            warning "Unrecognized logger level: not in #{LEVEL_LOOKUP.keys.inspect} or #{LEVEL_LOOKUP.values.inspect}"
            value
          end
        unless @logger.nil?
          @logger.level = value
        end
      end

      def logger
        @logger ||= Logger.new(logpath_for_env).tap do |logger|
          logger.level = log_level
        end
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

      def debug_dump
        builder.use Dumper, logger
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
        logging
        debug_dump
        goto_redirect
        cookies
        disable_caching
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
