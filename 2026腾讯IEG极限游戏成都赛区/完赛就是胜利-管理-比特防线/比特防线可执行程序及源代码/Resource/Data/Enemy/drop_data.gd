extends Resource
class_name DropData

@export var item_type: String = "gold"  # gold, item, health
@export var item_id: String = ""
@export var item_name: String = ""
@export var amount: int = 1
@export var drop_chance: float = 1.0  # 0-1
@export var min_amount: int = 1
@export var max_amount: int = 5

func get_drop_amount() -> int:
	if min_amount == max_amount:
		return min_amount
	return randi_range(min_amount, max_amount)

func roll_drop() -> bool:
	return randf() <= drop_chance
