extends StatusEffect
class_name StunEffect

@export var stun_duration: float = 2.0

var was_moving: bool = false
var target: Node2D = null

func _init():
	effect_name = "stun"

func _on_apply(target_node: Node2D) -> void:
	target = target_node
	duration = stun_duration
	remaining_time = stun_duration
	
	# 停止移动
	if target.has_method("stop_movement"):
		was_moving = true
		target.stop_movement()
	
	# 停止攻击
	if target.has_method("disable_attack"):
		target.disable_attack()

func _on_remove(target_node: Node2D) -> void:
	# 恢复移动
	if was_moving and target and target.has_method("resume_movement"):
		target.resume_movement()
	
	# 恢复攻击
	if target and target.has_method("enable_attack"):
		target.enable_attack()
	
	target = null

func _on_stack() -> void:
	# 叠加时刷新持续时间
	remaining_time = stun_duration
