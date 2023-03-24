#!/usr/bin/env ruby
# frozen_string_literal: true

openssl_clone_path = '/Users/ansonjablinski/Developer/Repositories/3rdPARTY/openssl'
patch_path = 'patches/openssl-1.1.1s.patch'
magic_git_replacement_token = '<< to be replaced by prep_patch.rb in OpenSSL-SPM-LLS-fork >>'

diff = Dir.chdir(openssl_clone_path) do
  `git diff OpenSSL_1_1_1s..head`
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
      openssl_git_revision = Dir.chdir(openssl_clone_path) do
        `git rev-parse HEAD`.chomp
      end
      l.gsub! magic_git_replacement_token, openssl_git_revision
    end

    f.puts l
  end
end

puts 'Patch look good?'
puts '(Enter to continue, Ctrl+C to abort.)'
print '> '
$stdin.gets

system 'time make'
