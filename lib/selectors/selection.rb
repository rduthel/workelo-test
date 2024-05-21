class Selection
  attr_accessor :slots, :previous_slot, :current_slot, :next_slot, :end_of_day

  def initialize(slots:, previous_slot: nil, current_slot: nil, next_slot: nil, end_of_day: nil)
    @slots = slots
    @previous_slot = previous_slot
    @current_slot = current_slot
    @next_slot = next_slot
    @end_of_day = end_of_day
  end

  def select
    raise NotImplementedError
  end
end
