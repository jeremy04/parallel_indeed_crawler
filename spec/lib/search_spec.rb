require 'spec_helper'
require 'search'

describe Search do
  it 'can find ruby pittsburgh jobs' do
    VCR.use_cassette 'pittsburgh_ruby' do
      s = Search.new(city: 'Pittsburgh', query: 'ruby rails')
      company = s.retrieve_jobs.map { |j| j[:company] }.first
      expect(company).to eql('Bosch Software Innovations')
    end
  end
end
