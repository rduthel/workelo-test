require "json"
require "spec_helper"
require_relative "../lib/calendar"

RSpec.describe "calendar" do
  describe "#hourly_ranges" do
    let(:output) do
      raw_output = JSON.parse(File.read("spec/fixtures/outputs/hourly_ranges/step/#{step}/output.json"))
      raw_output.map do |hash|
        start_as_time = Time.new(hash["start"])
        end_as_time = Time.new(hash["end"])
        Slot.new(start_as_time, end_as_time)
      end
    end

    context "step 1" do
      let(:step) { 1 }
      it "works" do
        result = hourly_ranges(Time.new(2022, 8, 1), step)
        expect(result.map { |slot| [slot.start, slot.end] }).to match_array(output.map { |slot| [slot.start, slot.end] })
      end
    end

    context "step 2" do
      let(:step) { 2 }
      it "works" do
        result = hourly_ranges(Time.new(2022, 8, 1), step)
        expect(result.map { |slot| [slot.start, slot.end] }).to match_array(output.map { |slot| [slot.start, slot.end] })
      end
    end
  end

  describe "#free_slots" do
    let(:input) { JSON.parse(File.read("spec/fixtures/inputs/free_slots/step/#{step}/input.json")) }
    let(:output) do
      raw_output = JSON.parse(File.read("spec/fixtures/outputs/free_slots/step/#{step}/output.json"))
      raw_output.map do |hash|
        start_as_time = Time.new(hash["start"])
        end_as_time = Time.new(hash["end"])
        Slot.new(start_as_time, end_as_time)
      end
    end

    context "step 1" do
      let(:step) { 1 }

      it "works" do
        result = free_slots(input, step)
        expect(result.map { |slot| [slot.start, slot.end] }).to match_array(output.map { |slot| [slot.start, slot.end] })
      end
    end

    context "step 2" do
      let(:step) { 2 }

      it "works" do
        result = free_slots(input, step)
        expect(result.map { |slot| [slot.start, slot.end] }).to match_array(output.map { |slot| [slot.start, slot.end] })
      end
    end
  end

  describe "#common_free_slots" do
    let(:input_sandra) { JSON.parse(File.read("spec/fixtures/inputs/common_free_slots/step/#{step}/input_sandra.json")) }
    let(:input_andy) { JSON.parse(File.read("spec/fixtures/inputs/common_free_slots/step/#{step}/input_andy.json")) }
    let(:output) do
      raw_output = JSON.parse(File.read("spec/fixtures/outputs/common_free_slots/step/#{step}/output.json"))
      raw_output.map do |slot|
        {
          start: Time.new(slot["start"]),
          end: Time.new(slot["end"])
        }
      end
    end

    context "step 1" do
      let(:step) { 1 }

      it "works" do
        expect(common_free_slots(input_andy, input_sandra, step)).to match_array(output)
      end
    end

    context "step 2" do
      let(:step) { 2 }

      it "works" do
        expect(common_free_slots(input_andy, input_sandra, step)).to match_array(output)
      end
    end
  end
end
