require "date"
require_relative "../app/models/slot"

ONE_HOUR = 60 * 60
MINIMUM_STEP = ONE_HOUR
START_OF_DAY = 9
END_OF_DAY = 18

def date_at(date, hour)
  date_at_midnight = Time.new(date.year, date.month, date.day)
  date_at_midnight + hour * ONE_HOUR
end

def hourly_ranges(date, step)
  result = []
  start_of_date = date_at(date, START_OF_DAY)
  end_of_date = date_at(date, END_OF_DAY)

  while start_of_date + step * ONE_HOUR <= end_of_date
    range_start = start_of_date
    range_end = start_of_date + step * ONE_HOUR
    result.push({"start" => range_start, "end" => range_end})

    start_of_date += MINIMUM_STEP
  end

  result
end

def free_slots(busy_calendar, step)
  result = []
  busy_calendar_day_by_day = busy_calendar
    .map { |calendar| Slot.new(calendar["start"], calendar["end"]) }
    .group_by { |slot| slot.start.to_date }

  busy_calendar_day_by_day.each_pair do |day, busy_slots_of_day|
    search_before_start_of_day = false
    slots_of_day = hourly_ranges(day, step)
    busy_slots_of_day.each_with_index do |busy_slot, index|
      next_slot = busy_slots_of_day[index + 1]
      first_slot_before_start_of_day = index.zero? && busy_slot.start.hour > START_OF_DAY
      end_of_slot_before_end_of_day = busy_slot.end.hour < END_OF_DAY

      if first_slot_before_start_of_day && !search_before_start_of_day
        selection = SlotsBeforeCurrentSelection.new(slots: slots_of_day, start_of_busy_slot: busy_slot.start).select
        result.push(selection)
        search_before_start_of_day = true
        redo
      elsif next_slot
        selection = AfterCurrentSlotAndBeforeNextOne.new(slots: slots_of_day, end_of_busy_slot: busy_slot.end, start_of_next_busy_slot: next_slot.start).select
      elsif end_of_slot_before_end_of_day
        selection = AfterCurrentSlotAndBeforeEndOfDay.new(slots: slots_of_day, end_of_day: date_at(day, END_OF_DAY), end_of_busy_slot: busy_slot.end).select
      else
        selection = AfterCurrentSlotOrBetweenPreviousAndCurrent.new(slots: slots_of_day, busy_slot:, end_of_previous_slot: busy_slots_of_day[index - 1].end).select
      end

      result.push(selection)
    end
  end

  result.flatten.uniq
end

def common_free_slots(first_calendar, second_calendar, step)
  free_slots(first_calendar, step) & free_slots(second_calendar, step)
end

class SlotsBeforeCurrentSelection
  attr_accessor :slots, :start_of_busy_slot

  def initialize(slots:, start_of_busy_slot:)
    @slots = slots
    @start_of_busy_slot = start_of_busy_slot
  end

  def select
    slots.select { |slot| slot["end"] <= start_of_busy_slot }
  end
end

class AfterCurrentSlotAndBeforeNextOne
  attr_accessor :slots, :end_of_busy_slot, :start_of_next_busy_slot

  def initialize(slots:, end_of_busy_slot:, start_of_next_busy_slot:)
    @slots = slots
    @end_of_busy_slot = end_of_busy_slot
    @start_of_next_busy_slot = start_of_next_busy_slot
  end

  def select
    slots.select do |slot|
      after_current_slot = slot["start"] >= end_of_busy_slot
      before_next_slot = slot["end"] <= start_of_next_busy_slot
      after_current_slot && before_next_slot
    end
  end
end

class AfterCurrentSlotAndBeforeEndOfDay
  attr_accessor :slots, :end_of_day, :end_of_busy_slot

  def initialize(slots:, end_of_day:, end_of_busy_slot:)
    @slots = slots
    @end_of_day = end_of_day
    @end_of_busy_slot = end_of_busy_slot
  end

  def select
    slots.select do |slot|
      after_current_slot = slot["start"] >= end_of_busy_slot
      before_end_of_day = slot["end"] <= end_of_day
      after_current_slot && before_end_of_day
    end
  end
end

class AfterCurrentSlotOrBetweenPreviousAndCurrent
  attr_accessor :slots, :busy_slot, :end_of_previous_slot

  def initialize(slots:, busy_slot:, end_of_previous_slot:)
    @slots = slots
    @busy_slot = busy_slot
    @end_of_previous_slot = end_of_previous_slot
  end

  def select
    slots.select do |slot|
      after_previous_slot = slot["start"] >= end_of_previous_slot
      before_current_slot = slot["end"] <= busy_slot.start
      after_current_slot = slot["start"] >= busy_slot.end
      after_current_slot || (before_current_slot && after_previous_slot)
    end
  end
end
