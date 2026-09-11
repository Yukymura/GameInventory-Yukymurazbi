extends StatusEffect

class_name FreezeEffect

@export var slow_percent: float = 0.5  # 减速百分比（0.5 = 减速50%）

var original_speed: float = 0.0
var original_attack_speed: float = 0.0
var target: Node2D = null  # 存储目标引用

func _init():
	effect_name = "freeze"

func _on_apply(target_node: Node2D) -> void:
	target = target_node
	
	# 保存并降低移动速度
	if target.has_method("get_speed"):
		original_speed = target.get_speed()
		target.set_speed(original_speed * (1 - slow_percent))
	
	# 保存并降低攻击速度
	if target.has_method("get_attack_speed"):
		original_attack_speed = target.get_attack_speed()
		target.set_attack_speed(original_attack_speed * (1 - slow_percent))

func _on_remove(target_node: Node2D) -> void:
	# 恢复移动速度
	if target and target.has_method("set_speed"):
		target.set_speed(original_speed)
	
	# 恢复攻击速度
	if target and target.has_method("set_attack_speed"):
		target.set_attack_speed(original_attack_speed)
	
	target = null

func _on_stack() -> void:
	# 叠加时增加减速效果
	var new_slow = 1 - (1 - slow_percent) * stacks
	slow_percent = min(new_slow, 0.9)  # 最高减速90%
	
	# 更新速度（使用存储的target引用）
	if target and target.has_method("get_speed") and original_speed > 0:
		target.set_speed(original_speed * (1 - slow_percent))
	if target and target.has_method("get_attack_speed") and original_attack_speed > 0:
		target.set_attack_speed(original_attack_speed * (1 - slow_percent))
