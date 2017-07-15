require 'indeed-ruby'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/blank'
require 'pp'
require 'pmap'
require 'benchmark'


# Found this api key on GitHub, you SHOULD NOT commit your API KEYS, yes I'm talking to you JS devs ;) ;) ;)
# Yinz can use it :), it's not mine

INDEED_API_KEY = "1515288478458370"

class Hash
  def with_indifferent_access
    ActiveSupport::HashWithIndifferentAccess.new(self)
  end

  def nested_under_indifferent_access
    self
  end
end

class Search
  def initialize(city:, query:, client: Indeed::Client.new(INDEED_API_KEY), batch_size: 10)
    @city = city
    @client = client
    @batch_size = batch_size
    @params = {
      q: query,
      l: city,
      userip: "0.0.0.0",
      useragent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)"
    }
  end

  def get_jobs
    start, totalResults = get_initial_batch
    new_jobs = crawl(start, totalResults).flatten
  end

  private

  def get_initial_batch
    jobs = @client.search(@params).with_indifferent_access
    [jobs[:start], jobs[:totalResults]]
  end

  def crawl(start, totalResults)
    (start..totalResults).each_slice(@batch_size).pmap { |batch|
      jobs = @client.search(@params.dup.merge(start: batch.first-1)).with_indifferent_access
      results = jobs[:results]
      results.map { |result| filter(result.with_indifferent_access) }
    }
  end

  def filter(result)
    { 
      date: DateTime.parse(result[:date]),
      title: result[:jobtitle],
      company: result[:company],
      snippet: result[:snippet]
    }
  end
end

if ARGV[0].blank?
  puts "Please enter a keyword ( $ ruby search.rb \"ruby rails\" )"
  exit 1
end

puts "Keyword: #{ARGV[0]} .."

cities = ["San Francisco", "Pittsburgh", "Philadelphia", "Seattle", "San Diego", "Raleigh", "Chicago", "New York", "Washington DC", "Austin"]

results = cities.pmap do |city|
  s = Search.new(city: city, query: ARGV[0])
  jobs = []
  time = Benchmark.realtime do
    jobs = s.get_jobs
  end
  jobs = jobs.select { |job| job[:date] > 2.weeks.ago }
  puts
  jobs.sort_by { |j| j[:date] }.reverse.each do |job|
    puts "#{job[:date].strftime("%Y-%m-%d") } :: #{job[:company]} :: #{job[:title][0...50].chomp} :: #{city}"
  end
  ["Crawl #{city} took #{time} seconds, found #{jobs.size} results", jobs.size]
end

puts ""
puts "Stats"
puts ""
results.sort_by { |r| -r[1] }.each do |result| 
  puts result[0] 
end
