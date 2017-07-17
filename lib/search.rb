# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/object/blank'
require 'benchmark'
require 'indeed-ruby'
require 'pp'
require 'pmap'

# monkey patch for with_indifferent_access
class Hash
  def with_indifferent_access
    ActiveSupport::HashWithIndifferentAccess.new(self)
  end

  def nested_under_indifferent_access
    self
  end
end

# Search class that does the work
class Search

  # Found this api key on GitHub, you SHOULD NOT commit your API KEYS,
  # yes I'm talking to you JS devs ;) ;) ;)
  # Yinz can use it :), it's not mine

  INDEED_API_KEY = '1515288478458370'

  def initialize(city:, query:, client: Indeed::Client.new(INDEED_API_KEY))
    @city = city
    @client = client
    @batch_size = 10
    @params = {
      q: query,
      l: city,
      userip: '0.0.0.0',
      useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)'
    }
  end

  def retrieve_jobs
    start, total_results = start_initial_batch
    crawl(start, total_results).flatten
  end

  private

  def start_initial_batch
    jobs = @client.search(@params).with_indifferent_access
    [jobs[:start], jobs[:totalResults]]
  end

  def crawl(start, total_results)
    (start..total_results).each_slice(@batch_size).pmap do |batch|
      params = @params.dup.merge(start: batch.first - 1)
      jobs = @client.search(params).with_indifferent_access
      results = jobs[:results]
      results.map { |result| filter(result.with_indifferent_access) }
    end
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
