Gem::Specification.new do |spec|
  spec.name		= "xing-dev-assets"
  spec.version		= "1.0.0-beta"
  author_list = {
    "Judson Lester" => 'nyarly@gmail.com'
  }
  spec.authors		= author_list.keys
  spec.email		= spec.authors.map {|name| author_list[name]}
  spec.summary		= ""
  spec.description	= <<-EndDescription
  EndDescription

  spec.rubyforge_project= spec.name.downcase
  spec.homepage        = "http://nyarly.github.com/#{spec.name.downcase}"
  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=

  # Do this: y$@"
  # !!find lib bin doc spec spec_help -not -regex '.*\.sw.' -type f 2>/dev/null
  spec.files		= %w[
    lib/xing/dev-assets.rb
    lib/xing/dev-assets/cookie_setter.rb
    lib/xing/dev-assets/rack_app.rb
    lib/xing/dev-assets/logger.rb
    lib/xing/dev-assets/dumper.rb
    lib/xing/dev-assets/empty_file.rb
    lib/xing/dev-assets/goto_param.rb
    lib/xing/dev-assets/strip_incoming_cache_headers.rb
    spec_help/spec_helper.rb
    spec_help/gem_test_suite.rb
  ]

  spec.test_file        = "spec_help/gem_test_suite.rb"
  spec.licenses = ["MIT"]
  spec.require_paths = %w[lib/]
  spec.rubygems_version = "1.3.5"

  spec.has_rdoc		= true
  spec.extra_rdoc_files = Dir.glob("doc/**/*")
  spec.rdoc_options	= %w{--inline-source }
  spec.rdoc_options	+= %w{--main doc/README }
  spec.rdoc_options	+= ["--title", "#{spec.name}-#{spec.version} Documentation"]

  spec.add_dependency("rack", "~> 1.6")

  #spec.post_install_message = "Thanks for installing my gem!"
end
