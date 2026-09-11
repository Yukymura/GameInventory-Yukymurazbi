extends Node
class_name StatusEffectManager

# 当前激活的效果
var active_effects: Array[StatusEffect] = []
var visual_component: EffectVisualComponent = null

# 信号
signal effect_added(effect: StatusEffect)
signal effect_removed(effect: StatusEffect)

func _ready():
	# 延迟一帧获取视觉组件，确保所有子节点都已添加
	await get_tree().process_frame
	visual_component = get_parent().get_node_or_null("EffectVisualComponent")
	
	# 如果视觉组件不存在，创建它
	if not visual_component:
		visual_component = EffectVisualComponent.new()
		visual_component.name = "EffectVisualComponent"
		get_parent().add_child(visual_component)
		print("StatusEffectManager: 自动创建 EffectVisualComponent")

func _process(delta):
	# 更新所有效果
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		
		# 获取父节点（敌人）
		var parent_node = get_parent()
		if not parent_node or not is_instance_valid(parent_node):
			# 如果父节点无效，清除效果
			remove_effect(effect)
			continue
		
		# 更新效果
		effect.update(parent_node, delta)
		
		# 如果效果时间结束，移除
		if effect.remaining_time <= 0:
			remove_effect(effect)

# 添加效果
func add_effect(effect: StatusEffect) -> void:
	if not effect:
		return
	
	var parent_node = get_parent()
	if not parent_node:
		return
	
	# 检查是否已有同类效果
	var existing_effect = get_effect_by_name(effect.effect_name)
	
	if existing_effect:
		# 效果已存在
		if effect.is_stacking:
			# 可叠加：增加层数
			existing_effect.stack()
			# 刷新视觉特效的持续时间
			if visual_component:
				visual_component.add_effect_visual(effect.effect_name, existing_effect.remaining_time)
			print("效果叠加: ", effect.effect_name, " 层数: ", existing_effect.stacks)
		else:
			# 不可叠加：刷新持续时间
			existing_effect.remaining_time = effect.duration
			# 刷新视觉特效
			if visual_component:
				visual_component.add_effect_visual(effect.effect_name, effect.duration)
			print("效果刷新: ", effect.effect_name, " 持续时间: ", effect.duration)
	else:
		# 添加新效果
		active_effects.append(effect)
		effect.apply(parent_node)
		
		# 连接效果移除信号 - 修正：使用正确的参数数量
		if not effect.effect_removed.is_connected(_on_effect_removed):
			effect.effect_removed.connect(_on_effect_removed)
		
		# 触发射击信号
		effect_added.emit(effect)
		
		# 添加视觉特效
		if visual_component:
			visual_component.add_effect_visual(effect.effect_name, effect.duration)
		
		print("添加效果: ", effect.effect_name, " 持续时间: ", effect.duration, " 可叠加: ", effect.is_stacking)

# 移除效果
func remove_effect(effect: StatusEffect) -> void:
	var index = active_effects.find(effect)
	if index != -1:
		active_effects.remove_at(index)
		
		var parent_node = get_parent()
		if parent_node and is_instance_valid(parent_node):
			effect.remove(parent_node)
		
		# 断开信号连接
		if effect.effect_removed.is_connected(_on_effect_removed):
			effect.effect_removed.disconnect(_on_effect_removed)
		
		# 触发移除信号
		effect_removed.emit(effect)
		
		# 移除视觉特效
		if visual_component:
			visual_component.remove_effect_visual(effect.effect_name)
		
		print("移除效果: ", effect.effect_name)

# 效果移除回调 - 修正：只接收1个参数
func _on_effect_removed(target: Node2D) -> void:
	# 根据目标查找并移除效果
	var parent_node = get_parent()
	if parent_node == target:
		# 查找哪个效果被移除了
		for effect in active_effects:
			# 这里需要找到对应的效果，但由于信号是从effect发出的，
			# 我们无法直接知道是哪个效果，所以采用另一种方式
			pass
	# 实际上，我们不应该在这里处理，因为remove_effect已经被调用过了

# 通过名称移除效果
func remove_effect_by_name(effect_name: String) -> void:
	var effect = get_effect_by_name(effect_name)
	if effect:
		remove_effect(effect)

# 获取特定效果
func get_effect_by_name(effect_name: String) -> StatusEffect:
	for effect in active_effects:
		if effect.effect_name == effect_name:
			return effect
	return null

# 获取特定效果的所有实例（用于可叠加效果）
func get_effects_by_name(effect_name: String) -> Array[StatusEffect]:
	var results: Array[StatusEffect] = []
	for effect in active_effects:
		if effect.effect_name == effect_name:
			results.append(effect)
	return results

# 清除所有效果
func clear_all_effects() -> void:
	for effect in active_effects.duplicate():
		remove_effect(effect)
	
	# 清除所有视觉特效
	if visual_component:
		visual_component.active_effects.clear()

# 检查是否有特定效果
func has_effect(effect_name: String) -> bool:
	return get_effect_by_name(effect_name) != null

# 获取效果数量
func get_effect_count() -> int:
	return active_effects.size()

# 获取效果列表
func get_effects() -> Array[StatusEffect]:
	return active_effects.duplicate()

# 获取效果信息（用于调试和UI）
func get_effects_info() -> Dictionary:
	var info = {}
	for effect in active_effects:
		info[effect.effect_name] = {
			"remaining_time": effect.remaining_time,
			"duration": effect.duration,
			"stacks": effect.stacks,
			"is_stacking": effect.is_stacking
		}
	return info

# 暂停所有效果（例如游戏暂停时）
func pause_all_effects() -> void:
	set_process(false)

# 恢复所有效果
func resume_all_effects() -> void:
	set_process(true)

# 获取视觉组件
func get_visual_component() -> EffectVisualComponent:
	return visual_component

# 手动刷新所有视觉特效（当视觉效果不同步时使用）
func refresh_all_visuals() -> void:
	if visual_component:
		# 清除所有现有视觉特效
		for effect_name in visual_component.active_effects.keys():
			visual_component.remove_effect_visual(effect_name)
		
		# 重新添加所有视觉特效
		for effect in active_effects:
			visual_component.add_effect_visual(effect.effect_name, effect.remaining_time)
