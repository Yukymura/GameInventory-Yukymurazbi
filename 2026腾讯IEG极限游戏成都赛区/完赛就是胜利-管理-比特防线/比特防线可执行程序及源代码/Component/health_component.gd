class_name HealthComponent

extends Node

# 生命值属性
@export var max_health: float = 100.0
@export var current_health: float = 100.0

# 信号
signal health_changed(current_health: float, max_health: float)
signal died()

# 父节点引用
var parent = null

func _ready():
	parent = get_parent()
	if not parent:
		printerr("DirectionMovement需要挂在节点上")
	
	if parent.has_method("on_died"):
		died.connect(parent.on_died)
	current_health = max_health

# 受到伤害
func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
	
	SignalBus.create_damage_label_request.emit("-%.2f" % amount, parent.global_position)
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()

# 恢复生命值
func heal(amount: float) -> void:
	if current_health <= 0:
		return
	
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

# 设置生命值
func set_health(value: float) -> void:
	current_health = clamp(value, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()

func set_max_health(max_value: float) -> void:
	max_health = max_value
	health_changed.emit(current_health, max_health)

# 重置生命值
func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

# 获取生命值百分比
func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0

# 检查是否死亡
func is_dead() -> bool:
	return current_health <= 0
