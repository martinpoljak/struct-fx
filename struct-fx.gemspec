# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{struct-fx}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Kozák"]
  s.date = %q{2011-03-02}
  s.email = %q{martinkozak@martinkozak.net}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/struct-fx.rb",
    "test",
    "test.gif"
  ]
  s.homepage = %q{http://github.com/martinkozak/struct-fx}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.0}
  s.summary = %q{Declarative pure Ruby equivalent of C/C++ structs.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<frozen-objects>, [">= 0.2.0"])
      s.add_runtime_dependency(%q<bit-packer>, [">= 0.1.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<riot>, [">= 0.12.1"])
    else
      s.add_dependency(%q<frozen-objects>, [">= 0.2.0"])
      s.add_dependency(%q<bit-packer>, [">= 0.1.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<riot>, [">= 0.12.1"])
    end
  else
    s.add_dependency(%q<frozen-objects>, [">= 0.2.0"])
    s.add_dependency(%q<bit-packer>, [">= 0.1.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<riot>, [">= 0.12.1"])
  end
end

