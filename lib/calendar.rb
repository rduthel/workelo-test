require "date"

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

def after_current_slot_and_before_next_slot(calendar_slot, end_of_busy_slot, start_of_next_busy_slot)
  after_current_slot = calendar_slot["start"] >= end_of_busy_slot
  before_next_slot = calendar_slot["end"] <= start_of_next_busy_slot
  after_current_slot && before_next_slot
end

def after_current_slot_and_before_end_of_day(calendar_slot, day, end_of_busy_slot)
  after_current_slot = calendar_slot["start"] >= end_of_busy_slot
  before_end_of_day = calendar_slot["end"] <= date_at(day, END_OF_DAY)
  after_current_slot && before_end_of_day
end

def after_current_slot_or_between_previous_and_current(calendar_slot, slot, end_of_previous_slot)
  after_current_slot = calendar_slot["start"] >= slot.end
  before_current_slot = calendar_slot["end"] <= slot.start
  after_previous_slot = calendar_slot["start"] >= end_of_previous_slot
  after_current_slot || (before_current_slot && after_previous_slot)
end

def slots_before_current(calendar_slots, start_of_busy_slot)
  calendar_slots.select { |calendar_slot| calendar_slot["end"] <= start_of_busy_slot }
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
      first_slot_before_start_of_day = index.zero? && busy_slot.start.hour > START_OF_DAY
      next_slot = busy_slots_of_day[index + 1]
      end_of_slot_before_end_of_day = busy_slot.end.hour < END_OF_DAY
      if first_slot_before_start_of_day && !search_before_start_of_day
        result.push(slots_before_current(slots_of_day, busy_slot.start))
        search_before_start_of_day = true
        redo
      elsif next_slot
        start_of_next_busy_slot = next_slot.start
        result.push(slots_of_day.select { |calendar_slot| after_current_slot_and_before_next_slot(calendar_slot, busy_slot.end, start_of_next_busy_slot) })
      elsif end_of_slot_before_end_of_day
        result.push(slots_of_day.select { |calendar_slot| after_current_slot_and_before_end_of_day(calendar_slot, day, busy_slot.end) })
      else
        end_of_previous_slot = busy_slots_of_day[index - 1].end
        result.push(slots_of_day.select { |calendar_slot| after_current_slot_or_between_previous_and_current(calendar_slot, busy_slot, end_of_previous_slot) })
      end
    end
  end

  result.flatten.uniq
end

def common_free_slots(first_calendar, second_calendar, step)
  free_slots(first_calendar, step) & free_slots(second_calendar, step)
end

class Slot
  attr_accessor :start, :end

  def initialize(start_of_slot, end_of_slot)
    @start = Time.new(start_of_slot)
    @end = Time.new(end_of_slot)
  end
end
