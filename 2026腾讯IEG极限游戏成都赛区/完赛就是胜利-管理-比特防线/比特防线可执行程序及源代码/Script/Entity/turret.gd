extends Node2D

class_name Turret

@export var turret_on_texture: Texture
@export var turret_off_texture: Texture

@onready var attack_range_area: Area2D = $AttackRangeArea
@onready var cool_down_timer: Timer = $CoolDownTimer
@onready var attack_range_shape: CollisionShape2D = $AttackRangeArea/AttackRangeShape
@onready var shoot_point: Marker2D = $Texture/ShootPoint
@onready var texture: Sprite2D = $Texture
@onready var progress_bar = $ProgressBar

# 塔属性
@export var ammo_scene: PackedScene

@export var attack_range: float = 150
@export var fire_rate: float = 1.0  # 每秒射击次数

# 弹药系统
@export var max_ammo: int = 10  # 最大弹药容量

# 内部变量
var current_target: Enemy = null
var can_shoot: bool = true
var is_reloading: bool = false
var reload_timer: float = 0.0

var ammo_array: Array[Ammo] = []  # 储存弹药的数组
var enemies_in_range: Array[Enemy] = [] # 范围内的敌人

# 信号
signal ammo_updated(current_ammo: int, max_ammo: int)

func _ready() -> void:
	# 设置冷却时间
	cool_down_timer.wait_time = 1.0 / fire_rate
	
	# 设置攻击范围
	attack_range_shape.shape.radius = attack_range
	
	# 连接信号
	attack_range_area.area_entered.connect(on_enemy_entered)
	attack_range_area.area_exited.connect(on_enemy_exited)
	cool_down_timer.timeout.connect(on_cooldown_timer_timeout)
	ammo_updated.connect(on_ammo_update)
	SignalBus.turret_range_changed.connect(func(r: int):
		attack_range_shape.shape.radius = r
		)
	SignalBus.turret_cooldown_changed.connect(func(r: float):
		cool_down_timer.wait_time = (1.0 / fire_rate) / (1 + r)
		)

func _process(_delta: float) -> void:
	
	# 更新当前目标（选择最前面的敌人）
	update_current_target()
	
	# 如果有目标且可以射击且有弹药，尝试射击
	if current_target and can_shoot and not ammo_array.is_empty():
		shot()

func on_ammo_update(num: int, max_num: int) -> void:
	texture.texture = turret_on_texture if num > 0 else turret_off_texture
	progress_bar.max_value = max_num
	progress_bar.value = num

# 向子弹数组里添加子弹
func add_ammo_to_array(ammo: Ammo) -> void:
	if ammo_array.size() >= max_ammo:
		return
	ammo_array.append(ammo)
	
	# 发射弹药更新信号
	ammo_updated.emit(ammo_array.size(), max_ammo)

# 消耗弹药（移除第一个弹药）
func consume_ammo() -> Ammo:
	if ammo_array.is_empty():
		return null
	
	var consumed_ammo = ammo_array.pop_front()
	ammo_updated.emit(ammo_array.size(), max_ammo)
	
	return consumed_ammo

# 获取当前弹药数量
func get_ammo_count() -> int:
	return ammo_array.size()

# 检查是否有弹药
func has_ammo() -> bool:
	return not ammo_array.is_empty()

# 清空所有弹药
func clear_ammo() -> void:
	ammo_array.clear()
	ammo_updated.emit(0, max_ammo)

# 打出子弹数组的第一个子弹
func shot() -> void:
	if not current_target or not is_instance_valid(current_target):
		return
	
	if ammo_array.is_empty():
		return
	
	can_shoot = false
	cool_down_timer.start()
	
	# 消耗第一发弹药
	SignalBus.play_sfx.emit("shoot")
	var consumed_ammo = consume_ammo()
	if consumed_ammo == null:
		return
	
	consumed_ammo.set_direction(shoot_point.global_position.direction_to(current_target.global_position))
	add_child(consumed_ammo)

# 冷却计时器结束时尝试发射子弹
func on_cooldown_timer_timeout() -> void:
	can_shoot = true
	
	# 如果有目标且还有弹药，立即射击
	if current_target and is_instance_valid(current_target) and not ammo_array.is_empty():
		shot()

# 更新当前目标（选择最前面的敌人）
func update_current_target() -> void:
	texture.look_at(current_target.global_position if current_target else global_position + Vector2.RIGHT)
	if enemies_in_range.is_empty():
		current_target = null
		return
	
	# 选择最前面的敌人（根据路程进度或距离终点距离）
	var front_enemy = enemies_in_range[0]
	var front_progress = front_enemy.get_progress() if front_enemy.has_method("get_progress") else 0.0
	
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var progress = enemy.get_progress() if enemy.has_method("get_progress") else 0.0
			if progress > front_progress:
				front_progress = progress
				front_enemy = enemy
	
	current_target = front_enemy

# 敌人进入攻击区域
func on_enemy_entered(enemy) -> void:
	"""
	敌人进入攻击范围
	"""
	if enemy and enemy.is_in_group("enemy"):
		enemies_in_range.append(enemy)
		update_current_target()

# 敌人离开攻击区域
func on_enemy_exited(enemy) -> void:
	"""
	敌人离开攻击范围
	"""
	if not enemy.is_in_group("enemy"):
		return
	if enemy in enemies_in_range:
		enemies_in_range.erase(enemy)
		
		# 如果离开的是当前目标，更新目标
		if current_target == enemy:
			update_current_target()
