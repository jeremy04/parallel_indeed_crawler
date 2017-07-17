require 'pathname'

# Namespace for root
module ParallelIndeedCrawler
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
