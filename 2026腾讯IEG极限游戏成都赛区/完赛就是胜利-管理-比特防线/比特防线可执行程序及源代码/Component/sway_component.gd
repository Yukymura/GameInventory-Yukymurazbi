extends Node2D
class_name SwayComponent

# 摇晃参数
@export var sway_enabled: bool = true
@export var sway_speed: float = 4.0  # 摇晃速度
@export var sway_amount: float = 5.0  # 摇晃幅度（度数）
@export var sway_offset: float = 0.0  # 摇晃偏移（起始角度）

# 拉伸参数
@export var stretch_enabled: bool = true
@export var stretch_speed: float = 8.0  # 拉伸速度
@export var stretch_amount: float = 0.1  # 拉伸幅度（0.1 = 10%）
@export var stretch_offset: float = 0.0  # 拉伸偏移

# 时间变量
var sway_time: float = 0.0
var stretch_time: float = 0.0

# 原始值
var original_rotation: float = 0.0
var original_scale: Vector2 = Vector2.ONE

# 目标节点
var target_node: Node = null

func _ready():
	# 获取目标节点（通常是父节点或指定的节点）
	target_node = get_parent()
	
	if not target_node:
		# 如果没有父节点，尝试从节点路径获取
		target_node = get_node("../Sprite2D")
	
	if target_node:
		# 保存原始值
		original_rotation = target_node.rotation
		original_scale = target_node.scale
	else:
		print("警告: SwayStretchComponent 找不到目标节点")

func _process(delta):
	if not target_node:
		return
	
	# 更新摇晃效果
	if sway_enabled:
		update_sway(delta)
	
	# 更新拉伸效果
	if stretch_enabled:
		update_stretch(delta)

# 更新摇晃
func update_sway(delta: float) -> void:
	sway_time += delta * sway_speed
	
	# 使用正弦波实现平滑摇晃
	var sway_angle = sin(sway_time + sway_offset) * deg_to_rad(sway_amount)
	target_node.rotation = original_rotation + sway_angle

# 更新拉伸
func update_stretch(delta: float) -> void:
	stretch_time += delta * stretch_speed
	
	# 使用正弦波实现平滑拉伸
	var stretch_x = 1.0 + sin(stretch_time + stretch_offset) * stretch_amount
	var stretch_y = 1.0 - sin(stretch_time + stretch_offset) * stretch_amount
	
	target_node.scale = Vector2(original_scale.x * stretch_x, original_scale.y * stretch_y)

# 设置摇晃参数
func set_sway(speed: float, amount: float, offset: float = 0.0) -> void:
	sway_speed = speed
	sway_amount = amount
	sway_offset = offset

# 设置拉伸参数
func set_stretch(speed: float, amount: float, offset: float = 0.0) -> void:
	stretch_speed = speed
	stretch_amount = amount
	stretch_offset = offset

# 启用/禁用摇晃
func set_sway_enabled(enabled: bool) -> void:
	sway_enabled = enabled
	if not enabled and target_node:
		target_node.rotation = original_rotation

# 启用/禁用拉伸
func set_stretch_enabled(enabled: bool) -> void:
	stretch_enabled = enabled
	if not enabled and target_node:
		target_node.scale = original_scale

# 重置所有效果
func reset() -> void:
	sway_time = 0.0
	stretch_time = 0.0
	if target_node:
		target_node.rotation = original_rotation
		target_node.scale = original_scale

# 设置目标节点
func set_target(node: Node2D) -> void:
	target_node = node
	if target_node:
		original_rotation = target_node.rotation
		original_scale = target_node.scale
