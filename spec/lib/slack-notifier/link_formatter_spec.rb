# encoding: utf-8
require 'spec_helper'

describe SN::Notifier::LinkFormatter do

  describe "::format" do

    it "formats html links" do
      formatted = described_class.format("Hello World, enjoy <a href='http://example.com'>this</a>.")
      expect( formatted ).to include("<http://example.com|this>")
    end

    it "formats markdown links" do
      formatted = described_class.format("Hello World, enjoy [this](http://example.com).")
      expect( formatted ).to include("<http://example.com|this>")
    end

    it "formats markdown links with no title" do
      formatted = described_class.format("Hello World, enjoy [](http://example.com).")
      expect( formatted ).to include("<http://example.com>")
    end

    it "handles multiple html links" do
      formatted = described_class.format("Hello World, enjoy <a href='http://example.com'>this</a><a href='http://example2.com'>this2</a>.")
      expect( formatted ).to include("<http://example.com|this>")
      expect( formatted ).to include("<http://example2.com|this2>")
    end

    it "handles multiple markdown links" do
      formatted = described_class.format("Hello World, enjoy [this](http://example.com)[this2](http://example2.com).")
      expect( formatted ).to include("<http://example.com|this>")
      expect( formatted ).to include("<http://example2.com|this2>")
    end

    it "handles mixed html & markdown links" do
      formatted = described_class.format("Hello World, enjoy [this](http://example.com)<a href='http://example2.com'>this2</a>.")
      expect( formatted ).to include("<http://example.com|this>")
      expect( formatted ).to include("<http://example2.com|this2>")
    end

    if "".respond_to? :scrub
      context "when on ruby 2.1+ or have string-scrub installed" do
        it "handles invalid unicode sequences" do
          expect {
            described_class.format("This sequence is invalid: \255")
          }.not_to raise_error
        end

        it "replaces invalid unicode sequences with the unicode replacement character" do
          formatted = described_class.format("\255")
          expect(formatted).to eq "\uFFFD"
        end
      end
    end

    it "doesn't replace valid Japanese" do
      formatted = described_class.format("こんにちは")
      expect(formatted).to eq "こんにちは"
    end

  end

end
