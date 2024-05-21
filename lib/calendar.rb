require "date"

ONE_HOUR = 60 * 60

def date_at(date, hour)
  date_at_midnight = Time.new(date.year, date.month, date.day)
  date_at_midnight + hour * ONE_HOUR
end

def hourly_ranges(date, step)
  result = []
  start_of_day = date_at(date, 9)
  end_of_day = date_at(date, 18)

  while start_of_day + step * ONE_HOUR <= end_of_day
    range_start = start_of_day
    range_end = start_of_day + step * ONE_HOUR
    result.push({"start" => range_start, "end" => range_end})

    start_of_day += ONE_HOUR
  end

  result
end

def free_slots(busy_days, step)
  result = []
  busy_days_by_day = busy_days.group_by { |slot| Time.new(slot["start"]).to_date }

  busy_days_by_day.each_key do |day|
    search_before_9 = false
    calendar_slots = hourly_ranges(day, step)
    busy_slots = busy_days_by_day[day]
    busy_slots.each_with_index do |busy_slot, index|
      start_of_busy_slot = Time.new(busy_slot["start"])
      end_of_busy_slot = Time.new(busy_slot["end"])
      if index.zero? && start_of_busy_slot.hour > 9 && !search_before_9
        result.push(calendar_slots.select { |calendar_slot| calendar_slot["end"] <= start_of_busy_slot })
        search_before_9 = true
        redo
      elsif busy_slots[index + 1]
        start_of_next_busy_slot = Time.new(busy_slots[index + 1]["start"])
        result.push(calendar_slots.select do |calendar_slot|
          before_next_slot = calendar_slot["end"] <= start_of_next_busy_slot
          after_current_slot = calendar_slot["start"] >= end_of_busy_slot
          before_next_slot && after_current_slot
        end)
      elsif end_of_busy_slot.hour < 18
        result.push(calendar_slots.select do |calendar_slot|
          after_current_slot = calendar_slot["start"] >= end_of_busy_slot
          before_end_of_day = calendar_slot["end"] <= date_at(day, 18)
          after_current_slot && before_end_of_day
        end)
      else
        result.push(calendar_slots.select do |calendar_slot|
          after_current_slot = calendar_slot["start"] >= end_of_busy_slot
          before_current_slot = calendar_slot["end"] <= start_of_busy_slot
          after_previous_slot = calendar_slot["start"] >= Time.new(busy_slots[index - 1]["end"])
          after_current_slot || (before_current_slot && after_previous_slot)
        end)
      end
    end
  end

  result.flatten.uniq
end

def common_free_slots
end
