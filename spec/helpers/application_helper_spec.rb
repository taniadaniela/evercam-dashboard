require 'spec_helper'

describe ApplicationHelper do

  context 'Without user session' do

    describe 'API_call' do
      before do
        stub_request(:get, "#{EVERCAM_API}test").
          to_return(:status => 200, :body => "", :headers => {})
      end

      it "doesn't add api keys" do
        expect(Typhoeus::Request).to receive(:new)
        .with("#{EVERCAM_API}test", {:method => :get, :body => {}, :params => {}, :timeout=>TIMEOUT, :connecttimeout=>TIMEOUT})
        .once.and_call_original
        API_call('test', :get)
      end
    end

  end

  context 'With user session' do

    let!(:user) {
      create(:active_user)
    }

    describe 'API_call' do
      before do
        stub_request(:get, "#{EVERCAM_API}test?api_id=#{user.api_id}&api_key=#{user.api_key}").
          to_return(:status => 200, :body => "", :headers => {})
        stub_request(:post, "#{EVERCAM_API}test").
          to_return(:status => 200, :body => "", :headers => {})
        stub_request(:patch, "#{EVERCAM_API}test").
          to_return(:status => 200, :body => "", :headers => {})
      end

      it "adds api keys to params if request is GET" do
        session['user'] = user.email
        expect(Typhoeus::Request).to receive(:new)
        .with("#{EVERCAM_API}test", {
          :method => :get,
          :body => {},
          :params => {:api_id => user.api_id,
                      :api_key => user.api_key},
          :timeout=>TIMEOUT,
          :connecttimeout=>TIMEOUT
        })
        .once.and_call_original
        API_call('test', :get)
      end

      it "adds api keys to body if request is POST" do
        session['user'] = user.email
        expect(Typhoeus::Request).to receive(:new)
        .with("#{EVERCAM_API}test", {
          :method => :post,
          :body => {:api_id => user.api_id,
                    :api_key => user.api_key},
          :params => {},
          :timeout=>TIMEOUT,
          :connecttimeout=>TIMEOUT
        })
        .once.and_call_original
        API_call('test', :post)
      end

      it "adds api keys to body if request is PATCH" do
        session['user'] = user.email
        expect(Typhoeus::Request).to receive(:new)
        .with("#{EVERCAM_API}test", {
          :method => :patch,
          :body => {:api_id => user.api_id,
                    :api_key => user.api_key},
          :params => {},
          :timeout=>TIMEOUT,
          :connecttimeout=>TIMEOUT
        })
        .once.and_call_original
        API_call('test', :patch)
      end
    end

  end

end