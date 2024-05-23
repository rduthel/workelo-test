class CalendarSlot
  ONE_HOUR = 60 * 60
  MINIMUM_STEP = ONE_HOUR
  START_OF_DAY = 9
  END_OF_DAY = 18

  public_constant :ONE_HOUR
  public_constant :MINIMUM_STEP
  public_constant :START_OF_DAY
  public_constant :END_OF_DAY

  attr_reader :date, :hour

  def initialize(date:, hour:)
    @date = date
    @hour = hour
  end

  def date_at
    date_at_midnight = Time.new(date.year, date.month, date.day)
    date_at_midnight + hour * ONE_HOUR
  end
end
