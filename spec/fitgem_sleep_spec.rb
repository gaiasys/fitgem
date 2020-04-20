require 'spec_helper'

describe Fitgem::Client do
  before(:each) do
    @client = Fitgem::Client.new({
      :consumer_key => '12345',
      :consumer_secret => '67890'
    })
  end

  describe '#sleep_on_date_range' do
    it 'formats the correct URI based on a start date and end date' do
      expect(@client).to receive(:get).with('/user/-/sleep/date/2020-03-21/2020-04-21.json')
      @client.sleep_on_date_range('2020-03-21', '2020-04-21')
    end

    it 'formats the correct URI based on a start date string and end date string' do
      today = Date.today
      today_string = today.strftime("%Y-%m-%d")
      yesterday = Date.today.prev_day
      yesterday_string = yesterday.strftime("%Y-%m-%d")

      expect(@client).to receive(:get).with("/user/-/sleep/date/#{yesterday_string}/#{today_string}.json")
      @client.sleep_on_date_range('yesterday', 'today')
    end

    it "raises an error when start date is invalid" do
      expect { @client.sleep_on_date_range('202-03-21', '2020-04-21') }.to raise_error(Fitgem::InvalidArgumentError)
    end

    it "raises an error when end date is invalid" do
      expect { @client.sleep_on_date_range('202-03-21', '2020-04-21') }.to raise_error(Fitgem::InvalidArgumentError)
    end
  end
end
