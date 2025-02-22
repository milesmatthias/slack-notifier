require 'spec_helper'

describe SN::Notifier do
  subject { described_class.new 'http://example.com' }

  describe "#initialize" do
    it "sets the given hook_url to the endpoint URI" do
      expect( subject.endpoint ).to eq URI.parse 'http://example.com'
    end

    it "sets the default_payload options" do
      subject = described_class.new 'http://example.com', channel: 'foo'
      expect( subject.channel ).to eq 'foo'
    end

    it "sets a custom http client" do
      client  = double("CustomClient")
      subject = described_class.new 'http://example.com', http_client: client
      expect( subject.http_client ).to eq client
    end
  end

  describe "#ping" do
    before :each do
      allow( SN::Notifier::DefaultHTTPClient ).to receive(:post)
    end

    it "passes the message through LinkFormatter" do
      expect( SN::Notifier::LinkFormatter ).to receive(:format)
                                              .with("the message")

      described_class.new('http://example.com').ping "the message", channel: 'foo'
    end

    context "with a default channel set" do

      before :each do
        @endpoint_double = instance_double "URI::HTTP"
        allow( URI ).to receive(:parse)
                    .and_return(@endpoint_double)
        subject.channel = '#default'
      end

      it "does not require a channel to ping" do
        expect{
          subject.ping "the message"
        }.not_to raise_error
      end

      it "uses default channel" do
        expect( SN::Notifier::DefaultHTTPClient ).to receive(:post)
                          .with @endpoint_double,
                                payload: '{"channel":"#default","text":"the message"}'

        subject.ping "the message"
      end

      it "allows override channel to be set" do
        expect( SN::Notifier::DefaultHTTPClient ).to receive(:post)
                          .with @endpoint_double,
                                payload: '{"channel":"new","text":"the message"}'

        subject.ping "the message", channel: "new"
      end

    end

    context "with default webhook" do
      it "posts with the correct endpoint & data" do
          @endpoint_double = instance_double "URI::HTTP"
          allow( URI ).to receive(:parse)
                      .with("http://example.com")
                      .and_return(@endpoint_double)

          expect( SN::Notifier::DefaultHTTPClient ).to receive(:post)
                            .with @endpoint_double,
                                  payload: '{"channel":"channel","text":"the message"}'

          described_class.new("http://example.com").ping "the message", channel: "channel"
      end
    end

    context "with a custom http_client set" do
      it "uses it" do
        endpoint_double = instance_double "URI::HTTP"
        allow( URI ).to receive(:parse)
                    .with("http://example.com")
                    .and_return(endpoint_double)
        client = double("CustomClient")
        expect( client ).to receive(:post)
                        .with endpoint_double,
                        payload: '{"text":"the message"}'

        described_class.new('http://example.com',http_client: client).ping "the message"
      end
    end
  end

  describe "#channel=" do
    it "sets the given channel" do
      subject.channel = "#foo"
      expect( subject.channel ).to eq "#foo"
    end
  end

  describe "#username=" do
    it "sets the given username" do
      subject.username = "foo"
      expect( subject.username ).to eq "foo"
    end
  end
end
