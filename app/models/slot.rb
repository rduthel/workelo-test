class Slot
  attr_accessor :start, :end

  def initialize(start_of_slot, end_of_slot)
    @start = start_of_slot
    @end = end_of_slot
  end

  def to_h
    {
      start: @start,
      end: @end
    }
  end
end
