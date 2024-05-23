class SlotsBeforeCurrentSelection < Selection
  def select
    slots.select { |slot| slot.end <= current_slot&.start }
  end
end
