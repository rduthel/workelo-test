class AfterCurrentSlotOrBetweenPreviousAndCurrentSelection < Selection
  def select
    slots.select do |slot|
      after_previous_slot = slot["start"] >= previous_slot&.end
      before_current_slot = slot["end"] <= current_slot&.start
      after_current_slot = slot["start"] >= current_slot&.end
      after_current_slot || (before_current_slot && after_previous_slot)
    end
  end
end
