require 'xing/dev-assets/cookie_setter'
require 'rack/mock'

describe Xing::DevAssets::CookieSetter do
  subject :middleware do
    described_class.new(app, "left", "right")
  end

  let :request do
    Rack::MockRequest.new(middleware)
  end

  let :app do
    proc{ [200, {}, ["What?!"]] }
  end

  it "should set the header" do
    expect(request.get("whatever")["Set-Cookie"]).to match(/left=right/)
  end
end
