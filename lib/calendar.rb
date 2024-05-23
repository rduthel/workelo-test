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

def slots_of_day(date, step)
  result = []
  start_of_date = date_at(date, START_OF_DAY)
  end_of_date = date_at(date, END_OF_DAY)

  while start_of_date + step * ONE_HOUR <= end_of_date
    range_start = start_of_date
    range_end = start_of_date + step * ONE_HOUR
    result.push(Slot.new(range_start, range_end))

    start_of_date += MINIMUM_STEP
  end

  result
end

def slot_in_busy_slot(busy_slot, slot)
  slot.start >= busy_slot.start && slot.end <= busy_slot.end
end

def overlapping_slots?(busy_slot, slot)
  busy_slot_in_slot = busy_slot.start >= slot.start && busy_slot.end <= slot.end
  busy_slot_end_in_slot = busy_slot.end > slot.start && busy_slot.end <= slot.end
  busy_slot_start_in_slot = busy_slot.start >= slot.start && busy_slot.start < slot.end

  slot_in_busy_slot(busy_slot, slot) || busy_slot_in_slot || busy_slot_end_in_slot || busy_slot_start_in_slot
end

def busy?(busy_slots_of_day, slot)
  busy_slots_of_day.any? { |busy_slot| overlapping_slots?(busy_slot, slot) }
end

def free_slots(busy_calendar, step)
  result = []
  busy_calendar_day_by_day = busy_calendar
    .map { |calendar| Slot.new(Time.new(calendar["start"]), Time.new(calendar["end"])) }
    .group_by { |slot| slot.start.to_date }

  busy_calendar_day_by_day.each_pair do |day, busy_slots_of_day|
    slots_of_day(day, step).each { |slot| result.push(slot) unless busy?(busy_slots_of_day, slot) }
  end

  result
end

def common_free_slots(first_calendar, second_calendar, step)
  free_slots(first_calendar, step).map(&:to_h) & free_slots(second_calendar, step).map(&:to_h)
end
