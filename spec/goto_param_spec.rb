require 'xing/dev-assets/goto_param'
require 'rack/mock'

describe Xing::DevAssets::GotoParam do
  subject :middleware do
    described_class.new(app)
  end

  let :request do
    Rack::MockRequest.new(middleware)
  end

  context "underlying app returns 404" do
    let :app do
      proc{ [404, {}, ["What?!"]] }
    end

    it "should redirect most request to new path" do
      expect(request.get("/somewhere")).to be_redirect
    end

    it "should redirect to new location with goto= param" do
      expect(request.get("/somewhere").location).to match(%r[goto=/somewhere])
    end

    it "should not redirect for assets, fonts, system requests" do
      expect(request.get("http://example.com/assets").status).to be(404)
      expect(request.get("http://example.com/fonts").status).to be(404)
      expect(request.get("http://example.com/system").status).to be(404)
    end

    it "should not redirect for some file extensions" do
      expect(request.get("http://example.com/index.html").status).to be(404)
      expect(request.get("http://example.com/readme.txt").status).to be(404)
      expect(request.get("http://example.com/favicon.ico").status).to be(404)
    end

    it "should not re-redirect when there are already goto params" do
      expect(request.get("/somewhere?goto=/somewhere").status).to be(404)
    end

    it "should retain any existing GET params" do
      expect(request.get("/somewhere?auth_token=123412341234").location).to match(%r[goto=])
      expect(request.get("/somewhere?auth_token=123412341234").location).to match(%r[auth_token=])
    end


  end


end
