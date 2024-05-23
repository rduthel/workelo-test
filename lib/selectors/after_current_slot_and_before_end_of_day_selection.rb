class AfterCurrentSlotAndBeforeEndOfDaySelection < Selection
  def select
    slots.select do |slot|
      after_current_slot = slot.start >= current_slot&.end
      before_end_of_day = slot.end <= end_of_day
      after_current_slot && before_end_of_day
    end
  end
end
