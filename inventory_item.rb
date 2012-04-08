module InventoryItem
  # TODO
  # when logic.rb's start filling up with common code related to inventory management start sticking such code here
  
  def to_inventory()
    move_to("Inventory")
    set_state("in_inventory", true)
    set_state("current_image", get_state("inventory_image"))
    set_state("draggable", true)
  end
  
end