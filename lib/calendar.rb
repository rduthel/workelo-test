require "date"
require_relative "calendar_slot"
require_relative "../app/models/slot"
require_relative "are_slots_overlapping"

def slots_of_day(date, step)
  result = []
  start_of_date = CalendarSlot.new(date:, hour: CalendarSlot::START_OF_DAY).date_at
  end_of_date = CalendarSlot.new(date:, hour: CalendarSlot::END_OF_DAY).date_at

  while start_of_date + step * CalendarSlot::ONE_HOUR <= end_of_date
    range_start = start_of_date
    range_end = start_of_date + step * CalendarSlot::ONE_HOUR
    result.push(Slot.new(range_start, range_end))

    start_of_date += CalendarSlot::MINIMUM_STEP
  end

  result
end

def busy?(busy_slots_of_day, slot)
  busy_slots_of_day.any? { |busy_slot| AreSlotsOverlapping.new(slot:, busy_slot:).overlapping? }
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
