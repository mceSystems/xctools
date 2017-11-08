#!/usr/bin/rake

require 'semantic'
require 'colorize'

### HELPERS ###

def generate_docs
  print "> Executing tests"
  sh "swift package generate-xcodeproj"
  sh "jazzy --clean --sdk macosx --xcodebuild-arguments -scheme,xctools --skip-undocumented --no-download-badge"
end

def any_git_changes?
  !`git status -s`.empty?
end

def build
  sh "swift build"
end

def current_version
  last_tag = `git describe --abbrev=0 --tags`
  Semantic::Version.new last_tag
end

def next_version
  current_version.increment! :minor
end

def bump_to_version(from, to)
  `git add .`
  `git commit -m "Bump version to #{to}"`
  `git tag #{to}`
  `git push origin --tags`
end

def print(message)
  puts message.colorize(:yellow)
end

def get_archive_url(version)
  'https://github.com/xcodeswift/xctools/archive/' + "#{version}" + '.tar.gz'
end

def download_archive(url)
  # follow link, output errors, no progress meter
  `curl -LSs #{url} -o xctools.tar.gz`
end

def get_checksum
  `shasum -a 256 xctools.tar.gz | awk '{printf $1}'`
end

def update_formula(version)
  path = 'Formula/xctools.rb'
  archive_url = get_archive_url(version)
  download_archive(archive_url)
  newSha = %Q{"#{get_checksum}"}
  newUrl = %Q{"#{archive_url}"}
  `sed -i "" 's|url .*$|url #{newUrl}|' #{path}`
  `sed -i "" 's|sha256 .*$|sha256 #{newSha}|' #{path}`
end

### TASKS ###

desc "Removes the build folder"
task :clean do
  print "> Cleaning build/ folder"
  `rm -rf build`
end

desc "Executes all the validation steps for CI"
task :ci => [:clean] do
  print "> Linting project"
  sh "swiftlint"
  print "> Building the project"
  sh "swift build"
  print "> Executing tests"
  sh "swift test"
end

desc "Bumps the version of xctools. It creates a new tagged commit and archives the binary to be published with the release"
task :release => [:clean] do
  abort '> Commit all your changes before starting the release' unless !any_git_changes?
  build
  print "> xctools built"
  generate_docs
  print "> Documentation generated"
  version = next_version
  bump_to_version(current_version, next_version)
  print "> Commit created and tagged with version: #{version}"
end

desc "Updates the Homebrew Formula to the values of the latest release. Creates a commit and pushes to the repository"
task :update_formula do
  version = current_version
  update_formula(version)
  print "> Updated formula to version: #{version}"
  `rm xctools.tar.gz`
  `git add Formula/xctools.rb`
  `git commit -m "Update Formula to #{version}" release`
  `git push origin release/#{version}`
  print "> Commit created and pushed to repository"
end

task :docs do
  generate_docs
end
