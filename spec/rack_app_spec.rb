require 'xing/dev-assets/rack_app'
require 'stringio'

describe Xing::DevAssets::RackApp do
  subject :rack_app do
    described_class.new.tap do |app|
      app.root_path = root_path
      app.backend_port = 3000
      app.logger = mock_logger
      app.builder = mock_builder
      app.out_stream = output_to
    end
  end

  let :root_path do
    "a root path"
  end

  let :output_to do
    StringIO.new
  end

  let :mock_logger do
    double("Logger")
  end

  let :mock_builder do
    instance_double(Rack::Builder, "builder")
  end

  it "should set up app correctly" do
    expect(mock_builder).to receive(:use).with(Xing::DevAssets::GotoParam)
    expect(mock_builder).to receive(:use).with(Xing::DevAssets::CookieSetter, "lrdBackendUrl", /3000/)
    expect(mock_builder).to receive(:use).with(Xing::DevAssets::CookieSetter, "xingBackendUrl", /3000/)
    expect(mock_builder).to receive(:use).with(Xing::DevAssets::StripIncomingCacheHeaders)
    expect(mock_builder).to receive(:use).with(Rack::CommonLogger, mock_logger)
    expect(mock_builder).not_to receive(:map).with(/livereload/)
    expect(mock_builder).to receive(:use).with(Rack::Static, hash_including(:root => root_path))
    expect(mock_builder).to receive(:run)

    rack_app.build
  end

  it "should set up livereload stubbing" do
    rack_app.env = "test"
    allow(mock_builder).to receive(:use)
    allow(mock_builder).to receive(:run)
    expect(mock_builder).to receive(:map).with(/livereload/)

    rack_app.build
  end

end
