class_name MoveComponent

extends Node

# 移动速度
@export var speed: float = 100.0

# 移动方向（单位向量）
var direction: Vector2 = Vector2.LEFT
var is_stopped: bool = false

# 父节点引用
var parent = null

func _ready():
	parent = get_parent()
	if not parent:
		printerr("DirectionMovement需要挂在节点上")

func _process(delta: float) -> void:
	if parent and not is_stopped:
		parent.position += direction * speed * delta

# 设置移动方向
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()

# 设置移动速度
func set_speed(new_speed: float) -> void:
	speed = new_speed

# 获取移动方向
func get_direction() -> Vector2:
	return direction

# 停止移动
func stop() -> void:
	is_stopped = true

# 恢复移动
func resume() -> void:
	is_stopped = false
