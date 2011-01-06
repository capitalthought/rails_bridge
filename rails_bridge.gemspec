# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails_bridge}
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["shock"]
  s.date = %q{2011-01-06}
  s.description = %q{Allows for easy embedding of content from a remote HTTP server and exporting of the Rails HTML layout into another template.}
  s.email = %q{billdoughty@capitalthought.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "app/controllers/rails_bridge/layout_bridge_controller.rb",
    "app/views/content.html.erb",
    "app/views/rails_bridge/layout_bridge/index.html.erb",
    "config/routes.rb",
    "lib/generators/content_bridge/USAGE",
    "lib/generators/content_bridge/content_bridge_generator.rb",
    "lib/generators/content_bridge/templates/content_bridge.rb",
    "lib/rails_bridge.rb",
    "lib/rails_bridge/content_bridge.rb",
    "lib/rails_bridge/content_request.rb",
    "lib/rails_bridge/engine.rb",
    "rails_bridge.gemspec",
    "script/console",
    "spec/dummy/.rspec",
    "spec/dummy/Rakefile",
    "spec/dummy/app/controllers/application_controller.rb",
    "spec/dummy/app/helpers/application_helper.rb",
    "spec/dummy/app/rails_bridge/content_bridges/tester.rb",
    "spec/dummy/app/rails_bridge/content_bridges/twitter_content_bridge.rb",
    "spec/dummy/app/rails_bridge/layout_bridge/layouts/application/content.html.erb",
    "spec/dummy/app/rails_bridge/layout_bridge/views/layouts/_partial.html.erb",
    "spec/dummy/app/views/layouts/_partial.html.erb",
    "spec/dummy/app/views/layouts/alternative.html.erb",
    "spec/dummy/app/views/layouts/application.html.erb",
    "spec/dummy/autotest/discover.rb",
    "spec/dummy/config.ru",
    "spec/dummy/config/application.rb",
    "spec/dummy/config/boot.rb",
    "spec/dummy/config/database.yml",
    "spec/dummy/config/environment.rb",
    "spec/dummy/config/environments/development.rb",
    "spec/dummy/config/environments/production.rb",
    "spec/dummy/config/environments/test.rb",
    "spec/dummy/config/initializers/backtrace_silencers.rb",
    "spec/dummy/config/initializers/inflections.rb",
    "spec/dummy/config/initializers/mime_types.rb",
    "spec/dummy/config/initializers/secret_token.rb",
    "spec/dummy/config/initializers/session_store.rb",
    "spec/dummy/config/locales/en.yml",
    "spec/dummy/config/routes.rb",
    "spec/dummy/db/development.sqlite3",
    "spec/dummy/db/test.sqlite3",
    "spec/dummy/public/404.html",
    "spec/dummy/public/422.html",
    "spec/dummy/public/500.html",
    "spec/dummy/public/favicon.ico",
    "spec/dummy/public/javascripts/application.js",
    "spec/dummy/public/javascripts/controls.js",
    "spec/dummy/public/javascripts/dragdrop.js",
    "spec/dummy/public/javascripts/effects.js",
    "spec/dummy/public/javascripts/prototype.js",
    "spec/dummy/public/javascripts/rails.js",
    "spec/dummy/public/stylesheets/.gitkeep",
    "spec/dummy/script/rails",
    "spec/dummy/spec/spec_helper.rb",
    "spec/integration/content_bridge_spec.rb",
    "spec/integration/engine_spec.rb",
    "spec/requests/layout_bridge_controller_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/content_bridge_helper.rb",
    "spec/support/layout_bridge_helper.rb",
    "spec/support/rails_bridge_helper.rb",
    "spec/support/test_server_helper.rb",
    "spec/unit/content_bridge_spec.rb",
    "spec/unit/content_request_spec.rb",
    "spec/unit/rails_bridge_spec.rb"
  ]
  s.homepage = %q{http://github.com/capitalthought/rails_bridge}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Bridges Rails with an external application.}
  s.test_files = [
    "spec/dummy/app/controllers/application_controller.rb",
    "spec/dummy/app/helpers/application_helper.rb",
    "spec/dummy/app/rails_bridge/content_bridges/tester.rb",
    "spec/dummy/app/rails_bridge/content_bridges/twitter_content_bridge.rb",
    "spec/dummy/autotest/discover.rb",
    "spec/dummy/config/application.rb",
    "spec/dummy/config/boot.rb",
    "spec/dummy/config/environment.rb",
    "spec/dummy/config/environments/development.rb",
    "spec/dummy/config/environments/production.rb",
    "spec/dummy/config/environments/test.rb",
    "spec/dummy/config/initializers/backtrace_silencers.rb",
    "spec/dummy/config/initializers/inflections.rb",
    "spec/dummy/config/initializers/mime_types.rb",
    "spec/dummy/config/initializers/secret_token.rb",
    "spec/dummy/config/initializers/session_store.rb",
    "spec/dummy/config/routes.rb",
    "spec/dummy/spec/spec_helper.rb",
    "spec/integration/content_bridge_spec.rb",
    "spec/integration/engine_spec.rb",
    "spec/requests/layout_bridge_controller_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/content_bridge_helper.rb",
    "spec/support/layout_bridge_helper.rb",
    "spec/support/rails_bridge_helper.rb",
    "spec/support/test_server_helper.rb",
    "spec/unit/content_bridge_spec.rb",
    "spec/unit/content_request_spec.rb",
    "spec/unit/rails_bridge_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<typhoeus>, ["~> 0.2.0"])
      s.add_runtime_dependency(%q<rails_bridge>, [">= 0"])
      s.add_runtime_dependency(%q<wdd-ruby-ext>, ["~> 0.2.3"])
      s.add_development_dependency(%q<rails>, [">= 3.0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_development_dependency(%q<capybara>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 0"])
      s.add_development_dependency(%q<eventmachine>, [">= 0"])
      s.add_development_dependency(%q<dalli>, [">= 0"])
      s.add_development_dependency(%q<syntax>, [">= 0"])
      s.add_development_dependency(%q<tm_helper>, [">= 0"])
      s.add_development_dependency(%q<typhoeus>, ["~> 0.2.0"])
      s.add_development_dependency(%q<activesupport>, [">= 2.3.8"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<typhoeus>, ["~> 0.2.0"])
      s.add_dependency(%q<rails_bridge>, [">= 0"])
      s.add_dependency(%q<wdd-ruby-ext>, ["~> 0.2.3"])
      s.add_dependency(%q<rails>, [">= 3.0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<capybara>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<dalli>, [">= 0"])
      s.add_dependency(%q<syntax>, [">= 0"])
      s.add_dependency(%q<tm_helper>, [">= 0"])
      s.add_dependency(%q<typhoeus>, ["~> 0.2.0"])
      s.add_dependency(%q<activesupport>, [">= 2.3.8"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<typhoeus>, ["~> 0.2.0"])
    s.add_dependency(%q<rails_bridge>, [">= 0"])
    s.add_dependency(%q<wdd-ruby-ext>, ["~> 0.2.3"])
    s.add_dependency(%q<rails>, [">= 3.0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<capybara>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<dalli>, [">= 0"])
    s.add_dependency(%q<syntax>, [">= 0"])
    s.add_dependency(%q<tm_helper>, [">= 0"])
    s.add_dependency(%q<typhoeus>, ["~> 0.2.0"])
    s.add_dependency(%q<activesupport>, [">= 2.3.8"])
  end
end

