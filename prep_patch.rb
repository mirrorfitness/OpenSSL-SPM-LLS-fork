#!/usr/bin/env ruby
# frozen_string_literal: true

patch_path = 'patches/openssl-1.1.1s.patch'

diff = Dir.chdir('/Users/ansonjablinski/Developer/Repositories/3rdPARTY/openssl') do
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

    f.puts l
  end
end

puts 'Patch look good?'
puts '(Enter to continue, Ctrl+C to abort.)'
print '> '
$stdin.gets

system 'time make'
