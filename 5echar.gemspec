# frozen_string_literal: true

require_relative "lib/fiveechar/version"

# @param spec [Gem::Specification]
Gem::Specification.new do |spec|
  spec.name = "5echar"
  spec.version = FiveeChar::VERSION
  spec.authors = ["0xmycf"]
  spec.email = ["mycf.mycf.mycf@gmail.com"]

  spec.summary = "Manage simple 5e Characters and create sheet cheets as pdf for all of their abilities."
  spec.homepage = "https://www.github.com/0xmycf/5echar"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.4"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://www.github.com/0xmycf/5echar"
  spec.metadata["changelog_uri"] = "https://www.github.com/0xmycf/5echar/todo"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["**/*.rb", "LICENSE.txt", "README.md",
                   "CHANGELOG.md", "exe/5echar", "bin/5echar",
                   "Gemfile", "Gemfile.lock" ]

  #   Dir.chdir(__dir__) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (File.expand_path(f) == __FILE__) ||
  #       f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
  #   end
  # end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
