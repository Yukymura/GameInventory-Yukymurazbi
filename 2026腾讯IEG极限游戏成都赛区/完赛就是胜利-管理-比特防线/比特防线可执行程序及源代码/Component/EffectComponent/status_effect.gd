extends Resource
class_name StatusEffect

# 效果属性
@export var effect_name: String = "status"
@export var duration: float = 3.0  # 持续时间（秒）
@export var is_stacking: bool = false  # 是否可叠加
@export var max_stacks: int = 1  # 最大叠加层数

# 效果数据
var remaining_time: float = 0.0
var stacks: int = 1

# 信号
signal effect_applied(target: Node2D)
signal effect_removed(target: Node2D)
signal effect_updated(target: Node2D)

# 应用效果到目标
func apply(target: Node2D) -> void:
	remaining_time = duration
	_on_apply(target)
	effect_applied.emit(target)

# 移除效果
func remove(target: Node2D) -> void:
	_on_remove(target)
	effect_removed.emit(target)  # 只发送1个参数

# 更新效果（每帧调用）
func update(target: Node2D, delta: float) -> void:
	remaining_time -= delta
	_on_update(target, delta)
	
	if remaining_time <= 0:
		remove(target)

# 叠加效果
func stack(additional_stacks: int = 1) -> void:
	if is_stacking:
		stacks = min(stacks + additional_stacks, max_stacks)
		_on_stack()

# 子类需要实现的虚函数
func _on_apply(target: Node2D) -> void:
	pass

func _on_remove(target: Node2D) -> void:
	pass

func _on_update(target: Node2D, delta: float) -> void:
	pass

func _on_stack() -> void:
	pass
