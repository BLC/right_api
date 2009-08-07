# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{right_api}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["MoneyPools"]
  s.date = %q{2009-08-07}
  s.description = %q{A ruby wrapper for the RightScale api}
  s.email = %q{mpdev@businesslogic.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "README",
     "Rakefile",
     "VERSION.yml",
     "install.rb",
     "lib/right_api.rb",
     "lib/right_api/accessible_fragment.rb",
     "lib/right_api/http_server.rb",
     "lib/right_api/rightscale.rb",
     "right_api.gemspec",
     "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/moneypools/right_api}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A ruby wrapper for the RightScale api}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
  end
end
