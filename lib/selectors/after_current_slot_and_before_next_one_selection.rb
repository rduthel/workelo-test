class AfterCurrentSlotAndBeforeNextOneSelection < Selection
  def select
    slots.select do |slot|
      after_current_slot = slot["start"] >= current_slot&.end
      before_next_slot = slot["end"] <= next_slot&.start
      after_current_slot && before_next_slot
    end
  end
end
