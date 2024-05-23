class AreSlotsOverlapping
  attr_reader :slot, :busy_slot

  def initialize(slot:, busy_slot:)
    @slot = slot
    @busy_slot = busy_slot
  end

  def overlapping?
    slot_in_busy_slot || busy_slot_in_slot || busy_slot_end_in_slot || busy_slot_start_in_slot
  end

  private

  def slot_in_busy_slot
    slot.start >= busy_slot.start && slot.end <= busy_slot.end
  end

  def busy_slot_in_slot
    busy_slot.start >= slot.start && busy_slot.end <= slot.end
  end

  def busy_slot_end_in_slot
    busy_slot.end > slot.start && busy_slot.end <= slot.end
  end

  def busy_slot_start_in_slot
    busy_slot.start >= slot.start && busy_slot.start < slot.end
  end
end
