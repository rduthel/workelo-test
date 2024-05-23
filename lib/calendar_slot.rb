class CalendarSlot
  ONE_HOUR = 60 * 60
  MINIMUM_STEP = ONE_HOUR
  START_OF_DAY = 9
  END_OF_DAY = 18

  attr_reader :date, :step

  def initialize(date:, step:)
    @date = date
    @step = step
  end

  def slots_of_day
    result = []
    start_of_date = date_at(START_OF_DAY)
    end_of_date = date_at(END_OF_DAY)

    while start_of_date + step * ONE_HOUR <= end_of_date
      range_start = start_of_date
      range_end = start_of_date + step * ONE_HOUR
      result.push(Slot.new(range_start, range_end))

      start_of_date += MINIMUM_STEP
    end

    result
  end

  private

  def date_at(hour)
    date_at_midnight = Time.new(date.year, date.month, date.day)
    date_at_midnight + hour * ONE_HOUR
  end
end
