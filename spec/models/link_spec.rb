require "rails_helper"

RSpec.describe Link, type: :model do
  describe "#unfurl", :vcr do
    subject(:link) { described_class.new(url:) }
    let(:url) { "https://archiveofourown.org/collections/Dramione_Month_2023/works/50219086" }

    it "extracts the data from the URL" do
      link.unfurl!

      expect(link.title).to eq("Draco Malfoy and the Timeline-Turner by anxiousm3ss")
      expect(link.words).to eq("1,972")
      expect(link.chapters).to eq("1/1")
      expect(link.rating).to eq("Teen")
    end
  end
end
