extends AttackComponent

class_name MeleeAttack

func try_attack(target: Node2D) -> void:
	if not target or not is_instance_valid(target):
		return
	
	# 检查距离
	#var distance = parent.global_position.distance_to(target.global_position)
	#if distance <= attack_range and can_attack:
	if can_attack:
		perform_attack(target)

# 获取攻击范围（用于调试显示）
func get_attack_range() -> float:
	return attack_range
