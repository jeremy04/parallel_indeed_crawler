VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = ParallelIndeedCrawler.root.join('spec', 'vcr')
end
