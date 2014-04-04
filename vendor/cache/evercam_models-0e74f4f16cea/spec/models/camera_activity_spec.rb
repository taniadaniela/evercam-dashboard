require 'data_helper'
require 'rack_helper'


describe CameraActivity do

  subject { CameraActivity }

  describe '#to_s' do
    let(:camera0) { create(:camera, name: 'Test Camera') }
    let(:user0) { create(:user, forename: 'Tomasz', lastname: 'Jama') }
    let(:at0) { create(:access_token, user: user0) }
    let(:time) {Time.now}

    it 'returns human readable string for normal user' do
      activity0 = subject.new(camera: camera0, access_token: at0,
                              action: 'Test', done_at: time, ip: '1.1.1.1')
      expect(activity0.to_s).to eq("[#{camera0.exid}] Tomasz Jama Test at #{time.to_s} from #{activity0.ip}")
    end

    it 'returns human readable string for anonymous user' do
      activity0 = subject.new(camera: camera0, access_token: nil,
                              action: 'Test', done_at: time, ip: '1.1.1.1')
      expect(activity0.to_s).to eq("[#{camera0.exid}] Anonymous Test at #{time.to_s} from #{activity0.ip}")
    end
  end
end