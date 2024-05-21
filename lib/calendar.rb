require "date"
require_relative "../app/models/slot"
require_relative "selectors/selection"
require_relative "selectors/slots_before_current_selection"
require_relative "selectors/after_current_slot_and_before_next_one_selection"
require_relative "selectors/after_current_slot_and_before_end_of_day_selection"
require_relative "selectors/after_current_slot_or_between_previous_and_current_selection"

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
    busy_slots_of_day.each_with_index do |current_slot, index|
      next_slot = busy_slots_of_day[index + 1]
      first_slot_before_start_of_day = index.zero? && current_slot.start.hour > START_OF_DAY
      end_of_slot_before_end_of_day = current_slot.end.hour < END_OF_DAY

      if first_slot_before_start_of_day && !search_before_start_of_day
        selection = SlotsBeforeCurrentSelection.new(slots: slots_of_day, current_slot:).select
        result.push(selection)
        search_before_start_of_day = true
        redo
      elsif next_slot
        selection = AfterCurrentSlotAndBeforeNextOneSelection.new(slots: slots_of_day, current_slot:, next_slot:).select
      elsif end_of_slot_before_end_of_day
        selection = AfterCurrentSlotAndBeforeEndOfDaySelection.new(slots: slots_of_day, current_slot:, end_of_day: date_at(day, END_OF_DAY)).select
      else
        selection = AfterCurrentSlotOrBetweenPreviousAndCurrentSelection.new(slots: slots_of_day, current_slot:, previous_slot: busy_slots_of_day[index - 1]).select
      end

      result.push(selection)
    end
  end

  result.flatten.uniq
end

def common_free_slots(first_calendar, second_calendar, step)
  free_slots(first_calendar, step) & free_slots(second_calendar, step)
end
