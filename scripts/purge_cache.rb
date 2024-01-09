require 'optparse'
require 'net/http'
require 'json'
require 'base64'

REGEX_NOT_BLANK = /[^[:space:]]/

API_USERNAME = ENV['ENDPOINT_API_USERNAME']
API_PASSWORD = ENV['ENDPOINT_API_SECRET']
HTTP_BASIC_CREDENTIALS = Base64::encode64("#{API_USERNAME}:#{API_PASSWORD}")


def purge_all_cache(options)
  puts "Purging all items from cache..."
  Net::HTTP.start(options[:hostname], options[:hostport]) do |http|
    response = http.post('/tasks',
              {
                'verb' => 'PurgeCache'
              }.to_json,
              headers = {
                'Authorization' => "Basic #{HTTP_BASIC_CREDENTIALS}"
              })
      raise response.code unless response.is_a?(Net::HTTPSuccess)
  end
  puts "Done."
end

def purge_identifiers_from_cache(options, identifiers)
  puts "Purging cache for #{identifiers.size} items..."
  Net::HTTP.start(options[:hostname], options[:hostport]) do |http|
    identifiers.each do |identifier|
      response = http.post('/tasks',
              {
                'verb' => 'PurgeItemFromCache',
                'identifier' => identifier
              }.to_json,
              headers = {
                'Authorization' => "Basic #{HTTP_BASIC_CREDENTIALS}"
              })
      raise response.class unless response.is_a?(Net::HTTPSuccess)
    end
  end
  puts "Done."
end

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"
  opts.on("-h", "--hostname", String, "Cantaloupe service hostname")
  opts.on("-p", "--port", String, "Cantaloupe service port")

  opts.on("-A", "--all", TrueClass, "Purge all items from cache")
  opts.on("-i", "--identifier [IDENTIFIER]", String, "Purge one identifier from cache")
  opts.on("-f", "--file [FILE]", String, "Provide a file with identifiers to purge from cache, separated by newlines")
end

options = {}
parser.parse!(into: options)

options[:hostname] ||= 'localhost'
options[:hostport] ||= 8182

if options[:all]
  purge_all_cache(options)
  exit
elsif options[:identifier]
  purge_identifiers_from_cache(options, [options[:identifier]])
elsif options[:file]
  puts "Purging cache from file #{options[:file]}"
  identifiers = []
  File.readlines(options[:file], chomp: true).each do |line|
    identifiers << line
  end
  purge_identifiers_from_cache(options, identifiers)
else
  puts options
  puts "Must provide the -A, -i, or -f flag to specify which items to purge.\n\n"
  puts parser
  exit
end
