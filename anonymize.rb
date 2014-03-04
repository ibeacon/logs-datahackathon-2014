#!/usr/bin/env ruby
require 'json'
require 'digest/md5'

ROOT_PATH = File.expand_path(File.dirname(__FILE__))

log_files = Dir[File.join(ROOT_PATH, "*.log")]
puts log_files

print 'Would you like to anonymize all those files? [y/N]: '
reponse = gets.chomp

if reponse.downcase == 'y'
  puts 'anonymizing...'
  log_files.each do |log_file|
    File.open("#{log_file}-anonymized", 'w') do |anonymized_file|
      File.open(log_file).each do |line|
        split_line = line.split("\t", 3)
        if split_line.size == 3
          timestamp, tag, json_data = split_line
          data = JSON.parse json_data
          
          new_name = Digest::MD5.hexdigest data['device']['identifier_for_vendor']
          data['device']['name'] = new_name

          anonymized_file.puts [timestamp, tag, data.to_json].join "\t"
        else
          $stderr.puts "Error for line:\n#{line}"
        end
      end
    end
  end
end

