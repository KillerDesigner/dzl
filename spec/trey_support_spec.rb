require 'spec_helper'
require 'rack/test'

describe 'trey support' do
  include Rack::Test::Methods

  def app; Diesel::Examples::App; end

  describe '/page_insights' do
    req_params = {
      page_ids: [1, 2, 3].join(' '),
      metrics: ['these', 'those'].join(' '),
      since: '2012-01-01',
      until: '2012-02-01'
    }

    opt_params = {
      interval: 'week'
    }

    bad_params = {
      post_ids: [4, 5, 6].join(' '),
      limit: 100,
      sort: 'these',
      order: 'descending'
    }

    it "responds 404 to a request with no parameters" do
      get '/page_insights' do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 4 # required params
        errors.values.each {|v| v.should == 'missing_required_param'}
      end
    end

    it "responds 404 with only optional parameters" do
      get('/page_insights', opt_params) do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 4 # required params
        errors.values.each {|v| v.should == 'missing_required_param'}
      end
    end

    it "responds 200 to a request with required parameters provided" do
      get('/page_insights', req_params) do |response|
        response.status.should == 200
      end
    end

    it "allows optional parameters in addition to the required params" do
      get('/page_insights', req_params.merge(opt_params)) do |response|
        response.status.should == 200
      end
    end

    it "understands array parameters" do
      get('/page_insights', req_params) do |response|
        response.status.should == 200
        JSON.parse(response.body)['page_ids'].should == ['1', '2', '3']
      end
    end

    it "understands date parameters" do
      get('/page_insights', req_params) do |response|
        response.status.should == 200
        JSON.parse(response.body)['since'].should == '2012-01-01'
      end
    end

    it "responds 404 to a request with required parameters improperly formatted" do
      get('/page_insights', req_params.merge(since: 'not a date')) do |response|
        response.status.should == 404
        errors = JSON.parse(response.body)['errors']['/page_insights']
        errors.size.should == 1
        errors.values.each {|v| v.should == 'type_conversion_error'}
      end
    end
  end
end