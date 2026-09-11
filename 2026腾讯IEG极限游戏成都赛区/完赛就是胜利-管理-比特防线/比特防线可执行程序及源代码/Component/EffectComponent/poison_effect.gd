extends StatusEffect

class_name PoisonEffect

@export var damage_per_second: float = 5.0
@export var damage_interval: float = 1.0

var damage_timer: float = 0.0
var target: Node2D = null

func _init():
	effect_name = "poison"

func _on_apply(target_node: Node2D) -> void:
	target = target_node
	damage_timer = 0.0

func _on_update(target_node: Node2D, delta: float) -> void:
	damage_timer += delta
	if damage_timer >= damage_interval:
		damage_timer = 0.0
		if target and target.has_method("take_damage"):
			target.take_damage(damage_per_second * damage_interval * stacks)

func _on_remove(target_node: Node2D) -> void:
	target = null

func _on_stack() -> void:
	# 叠加时增加持续时间
	remaining_time += duration * 0.5
	# 增加伤害
	damage_per_second = damage_per_second * (1 + (stacks - 1) * 0.3)
