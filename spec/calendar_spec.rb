require "json"
require "spec_helper"
require_relative "../lib/calendar"

RSpec.describe "calendar" do
  describe "#hourly_ranges" do
    let(:output) do
      raw_output = JSON.parse(File.read("spec/fixtures/outputs/hourly_ranges/step/#{step}/output.json"))
      raw_output.each do |hash|
        hash["start"] = Time.new(hash["start"])
        hash["end"] = Time.new(hash["end"])
      end
    end

    context "step 1" do
      let(:step) { 1 }
      it "works" do
        expect(hourly_ranges(Time.new(2022, 8, 1), step)).to match_array(output)
      end
    end

    context "step 2" do
      let(:step) { 2 }
      it "works" do
        expect(hourly_ranges(Time.new(2022, 8, 1), step)).to match_array(output)
      end
    end
  end

  describe "#free_slots" do
    context "step 2" do
      let(:input) { JSON.parse(File.read("spec/fixtures/inputs/free_slots/step/#{step}/input.json")) }
      let(:output) do
        raw_output = JSON.parse(File.read("spec/fixtures/outputs/free_slots/step/#{step}/output.json"))
        raw_output.each do |hash|
          hash["start"] = Time.new(hash["start"])
          hash["end"] = Time.new(hash["end"])
        end
      end

      let(:step) { 2 }

      it "works" do
        expect(free_slots(input, step)).to match_array(output)
      end
    end
  end
end
