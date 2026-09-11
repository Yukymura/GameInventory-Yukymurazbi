extends StatusEffect

class_name SlowEffect

@export var slow_percent: float = 0.5  # 减速百分比（0.5 = 减速50%）
@export var affects_movement: bool = true
@export var affects_attack_speed: bool = true

func _init():
	effect_name = "slow"

var original_speed: float = 0.0
var original_attack_speed: float = 0.0

func _on_apply(target: Node2D) -> void:
	# 保存原始速度
	if affects_movement and target.has_method("get_speed"):
		original_speed = target.get_speed()
		target.set_speed(original_speed * (1 - slow_percent))
	
	# 保存原始攻击速度
	if affects_attack_speed and target.has_method("get_attack_speed"):
		original_attack_speed = target.get_attack_speed()
		target.set_attack_speed(original_attack_speed * (1 - slow_percent))

func _on_remove(target: Node2D) -> void:
	# 恢复原始速度
	if affects_movement and target.has_method("set_speed"):
		target.set_speed(original_speed)
	
	# 恢复原始攻击速度
	if affects_attack_speed and target.has_method("set_attack_speed"):
		target.set_attack_speed(original_attack_speed)

func _on_stack() -> void:
	# 叠加时增加减速效果
	var new_slow = 1 - (1 - slow_percent) * stacks
	slow_percent = min(new_slow, 0.9)  # 最高减速90%
