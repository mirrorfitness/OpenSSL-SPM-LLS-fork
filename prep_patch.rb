#!/usr/bin/env ruby
# frozen_string_literal: true

# Will change on occasion
patch_path = './patches/openssl-1.1.1s.patch'
openssl_tag_name = 'OpenSSL_1_1_1s'

# Won't change often, if at all
spm_repo_name = 'OpenSSL-SPM-LLS-fork'
openssl_repo_name = 'openssl-LLS-fork'
openssl_clone_path = "../#{openssl_repo_name}"
magic_git_replacement_token = '<< to be replaced by prep_patch.rb in OpenSSL-SPM-LLS-fork >>'

unless `pwd`.chomp.end_with? spm_repo_name
  raise "Please run this script from the root of #{spm_repo_name}. (Did you change the repo name when cloning?)"
end

unless Dir.exist? openssl_clone_path
  raise "Couldn't find openssl-LLS-fork at #{openssl_clone_path}"
end

openssl_git_revision = Dir.chdir(openssl_clone_path) do
  `git rev-parse HEAD`.chomp
end

diff = Dir.chdir(openssl_clone_path) do
  `git diff #{openssl_tag_name}..head -- . ':!README'`
end

diff_lines = diff.split("\n")

File.open(patch_path, 'w') do |f|
  # Please don't judge me for this
  skip_next = false
  diff_lines.each do |l|
    if l.start_with? 'diff --git'
      skip_next = true
      next
    end
    if skip_next
      skip_next = false
      next
    end

    if l.include? magic_git_replacement_token
      l.gsub! magic_git_replacement_token, openssl_git_revision
    end

    f.puts l
  end
end

puts "You're building from #{openssl_repo_name} @ #{openssl_git_revision}."
Dir.chdir(openssl_clone_path) do
  system "git show -s #{openssl_git_revision}"
end
puts "Is that correct? And does the patch at #{patch_path} look good?"
puts '(Enter to continue, Ctrl+C to abort.)'
print '> '
$stdin.gets

system 'time make'
