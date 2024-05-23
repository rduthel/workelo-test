require "date"
require_relative "calendar_slot"
require_relative "../app/models/slot"
require_relative "are_slots_overlapping"

def busy?(busy_slots_of_day, slot)
  busy_slots_of_day.any? { |busy_slot| AreSlotsOverlapping.new(slot:, busy_slot:).overlapping? }
end

def free_slots(busy_calendar, step)
  result = []
  busy_calendar_day_by_day = busy_calendar
    .map { |calendar| Slot.new(Time.new(calendar["start"]), Time.new(calendar["end"])) }
    .group_by { |slot| slot.start.to_date }

  busy_calendar_day_by_day.each_pair do |date, busy_slots_of_day|
    CalendarSlot.new(date:, step:).slots_of_day.each { |slot| result.push(slot) unless busy?(busy_slots_of_day, slot) }
  end

  result
end

def common_free_slots(first_calendar, second_calendar, step)
  free_slots(first_calendar, step).map(&:to_h) & free_slots(second_calendar, step).map(&:to_h)
end
