# 敌人

extends Area2D
class_name Enemy

# 移动组件
var move_component: MoveComponent
# 攻击组件
var attack_component: AttackComponent
# 生命值组件
var health_component: HealthComponent
# 状态效果管理器
var status_manager: StatusEffectManager = null
# 视觉效果组件
var visual_component: EffectVisualComponent = null
# 摇晃组件
var sway_component: SwayComponent = null

# 目标
var current_target: Node2D = null
var detection_range: float = 300.0

# 额外属性
var original_speed: float = 0.0
var original_attack_speed: float = 0.0
var attack_disabled: bool = false

# 信号
signal died

func _ready():
	add_to_group("enemy")
	
	# 获取组件
	move_component = get_move_component()
	attack_component = get_attack_component()
	health_component = get_health_component()
	
	# 添加状态效果管理器
	status_manager = get_node_or_null("StatusEffectManager")
	if not status_manager:
		status_manager = StatusEffectManager.new()
		status_manager.name = "StatusEffectManager"
		add_child(status_manager)
	
	# 添加视觉效果组件
	visual_component = get_node_or_null("EffectVisualComponent")
	if not visual_component:
		visual_component = EffectVisualComponent.new()
		visual_component.name = "EffectVisualComponent"
		add_child(visual_component)
	
	# 保存原始属性
	if move_component:
		original_speed = move_component.speed
	if attack_component:
		original_attack_speed = 1.0 / attack_component.attack_cooldown if attack_component.attack_cooldown > 0 else 1.0

	var sway = SwayComponent.new()
	sway.sway_speed = 2.0
	sway.sway_amount = 5.0
	sway.stretch_amount = 0.1
	add_child(sway)

func _physics_process(_delta: float) -> void:
	# 寻找目标
	if not current_target or not is_instance_valid(current_target):
		find_target()
	
	# 如果有目标，决定行为
	if current_target and not attack_disabled:
		var distance = global_position.x - current_target.global_position.x
		
		if attack_component:
			# 如果在攻击范围内，进行攻击
			if abs(distance) <= attack_component.attack_range:
				stop_movement()
				attack_component.try_attack(current_target)
			else:
				# 否则向目标移动
				move_towards_target()

# 寻找目标
func find_target() -> void:
	# 优先寻找基地
	var base = get_tree().get_first_node_in_group("base")
	if base:
		current_target = base
	else:
		# 如果没有基地，寻找防御塔
		var turrets = get_tree().get_nodes_in_group("turret")
		if not turrets.is_empty():
			var closest_turret = null
			var closest_distance = detection_range + 1
			for turret in turrets:
				var distance = global_position.distance_to(turret.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_turret = turret
			current_target = closest_turret

# 向目标移动
func move_towards_target() -> void:
	if move_component and current_target:
		var direction = (current_target.global_position - global_position).normalized()
		move_component.set_direction(Vector2(direction.x, 0))

# 停止移动
func stop_movement() -> void:
	if move_component:
		move_component.stop()

# 恢复移动
func resume_movement() -> void:
	if move_component:
		move_component.resume()

# 受到伤害
func take_damage(amount: float, damage_type: String = "normal") -> void:
	if health_component:
		health_component.take_damage(amount)
		
		# 根据伤害类型触发效果
		match damage_type:
			"fire":
				var burn = BurnEffect.new()
				# effect_name 已经在类中设置，不需要再手动设置
				burn.duration = 3.0
				burn.damage_per_second = 5.0
				add_status_effect(burn)
				print("施加燃烧效果")
			"poison":
				var poison = PoisonEffect.new()
				poison.duration = 5.0
				poison.damage_per_second = 3.0
				add_status_effect(poison)
				print("施加中毒效果")
			"ice":
				var freeze = FreezeEffect.new()
				freeze.duration = 2.0
				freeze.slow_percent = 0.5
				add_status_effect(freeze)
				print("施加冰冻效果")

# 添加负面效果
func add_status_effect(effect: StatusEffect) -> void:
	if status_manager:
		status_manager.add_effect(effect)

# 获取当前速度
func get_speed() -> float:
	if move_component:
		return move_component.speed
	return 0.0

# 设置速度
func set_speed(new_speed: float) -> void:
	if move_component:
		move_component.speed = new_speed

# 获取攻击速度
func get_attack_speed() -> float:
	if attack_component and attack_component.attack_cooldown > 0:
		return 1.0 / attack_component.attack_cooldown
	return 0.0

# 设置攻击速度
func set_attack_speed(new_attack_speed: float) -> void:
	if attack_component and new_attack_speed > 0:
		attack_component.attack_cooldown = 1.0 / new_attack_speed

# 禁用攻击
func disable_attack() -> void:
	attack_disabled = true

# 启用攻击
func enable_attack() -> void:
	attack_disabled = false

# 获取当前进度（用于塔防选择最前面的敌人）
func get_progress() -> float:
	# 对于向左移动，X坐标越小表示越靠前
	return -global_position.x

# 获取剩余距离（到目标的距离）
func get_remaining_distance() -> float:
	if current_target:
		return global_position.distance_to(current_target.global_position)
	return 0.0

func on_died():
	died.emit()
	SignalBus.play_sfx.emit("death")
	queue_free()

# 移动组件相关
func get_move_component() -> MoveComponent:
	for child in get_children():
		if child is MoveComponent:
			return child
	return null

# 攻击组件相关
func get_attack_component() -> AttackComponent:
	for child in get_children():
		if child is AttackComponent:
			return child
	return null

# 生命值组件相关
func get_health_component() -> HealthComponent:
	for child in get_children():
		if child is HealthComponent:
			return child
	return null

# 摇摆组件
func get_sway_component() -> SwayComponent:
	for child in get_children():
		if child is SwayComponent:
			return child
	return null
