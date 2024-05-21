class Slot
  attr_accessor :start, :end

  def initialize(start_of_slot, end_of_slot)
    @start = Time.new(start_of_slot)
    @end = Time.new(end_of_slot)
  end
end
