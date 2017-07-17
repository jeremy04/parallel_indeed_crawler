$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'vcr'
require 'parallel_indeed_crawler'

root = ParallelIndeedCrawler.root
Dir[root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'
end
