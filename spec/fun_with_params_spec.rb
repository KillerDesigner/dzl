require 'spec_helper'
require 'rack/test'
require 'diesel/examples/fun_with_params'

describe Diesel::Examples::FunWithParams do
  include Rack::Test::Methods

  def app; Diesel::Examples::FunWithParams; end

  describe '/foo' do
    describe "understands disallowed values" do
      it "for arrays" do
        all_good = ['ok', 'sweet', 'awesome'].join(' ')
        one_bad = ['zip'].join(' ')
        all_bad = ['zip', 'zilch', 'nada'].join(' ')
        mixed = ['ok', 'sweet', 'nada', 'nice'].join(' ')

        get('/foo', {foo: all_good}) do |response|
          response.status.should == 200
        end

        get('/foo', {foo: one_bad}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'disallowed_values_failed'
          }
        end

        get('/foo', {foo: all_bad}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'disallowed_values_failed'
          }
        end

        get('/foo', {foo: mixed}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'disallowed_values_failed'
          }
        end
      end
    end

    describe "required parameters" do
      it "arrays cannot be empty" do
        get('/foo', {foo: ''}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/foo'].should == {
            'foo' => 'empty_required_array'
          }
        end
      end

      it "strings cannot be empty" do
        get('/bar', {foo: ''}) do |response|
          response.status.should == 404
          JSON.parse(response.body)['errors']['/bar'].should == {
            'foo' => 'missing_required_param'
          }
        end
      end
    end

    describe "arbitrary array separator" do
      it "can split arrays on +" do
        ary = %w{one two three}
        bad = ary.join(' ')
        good = ary.join('+')

        get('/bar', {foo: bad}) do |response|
          response.status.should == 200
          JSON.parse(response.body)['params']['foo'].should == ['one two three']
        end

        get('/bar', {foo: good}) do |response|
          response.status.should == 200
          JSON.parse(response.body)['params']['foo'].should == ary
        end
      end
    end

    it "can split arrays on ," do
      ary = %w{one two three}
      bad = ary.join(' ')
      good = ary.join(',')

      get('/baz', {foo: bad}) do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['foo'].should == ['one two three']
      end

      get('/baz', {foo: good}) do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['foo'].should == ary
      end
    end
  end

  describe '/foo/:bar (:bar as string)' do
    it 'finds :bar properly' do
      get '/foo/omg' do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['bar'].should == 'omg'
      end
    end
  end

  describe '/foo/:bar (:bar as time)' do
    it 'converts :bar to time' do
      get '/foo/2012-01-01' do |response|
        response.status.should == 200
        JSON.parse(response.body)['params']['bar'].should == '2012-01-01T00:00:00-05:00'
      end
    end
  end
end