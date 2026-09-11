extends Node
class_name EnemyFactory

# 缓存所有敌人数据
@export var enemy_data_cache: Dictionary = {
	"enemy_001": preload("uid://bayos2okd7t3m"),
	"enemy_002": preload("uid://ox5snmtn56p7"),
	"enemy_003": preload("uid://x5d6c2xykshm"),
	"enemy_004": preload("uid://d4mwhasl0q0jd"),
	"enemy_005": preload("uid://d08g4ufo6strm"),
	"enemy_006": preload("uid://n0h2asbp1wgs"),
}

signal enemy_created(enemy: Enemy, data: EnemyData)


# 根据数据创建敌人
func create_enemy(data: EnemyData, position: Vector2) -> Enemy:
	var enemy = Enemy.new()
	enemy.global_position = position
	
	# 设置视觉
	setup_visual(enemy, data)
	
	# 设置碰撞体
	setup_collision(enemy, data)
	
	# 添加移动组件
	setup_movement(enemy, data)
	
	# 添加攻击组件
	setup_attack(enemy, data)
	
	# 添加生命值组件
	setup_health(enemy, data)
	
	# 添加自带效果
	setup_innate_effects(enemy, data)
	
	# 存储元数据
	enemy.set_meta("enemy_data", data)
	enemy.set_meta("reward_gold", data.reward_gold)
	enemy.set_meta("reward_exp", data.reward_exp)
	enemy.set_meta("drop_items", data.drop_items)
	enemy.set_meta("death_effect", data.death_effect)
	
	enemy_created.emit(enemy, data)
	return enemy

# 根据ID创建敌人
func create_enemy_by_id(enemy_id: String, position: Vector2) -> Enemy:
	if enemy_data_cache.has(enemy_id):
		return create_enemy(enemy_data_cache[enemy_id], position)
	else:
		print("未找到敌人数据: ", enemy_id)
		return null

# 根据名称创建敌人
func create_enemy_by_name(name: String, position: Vector2) -> Enemy:
	for data in enemy_data_cache.values():
		if data.enemy_name == name:
			return create_enemy(data, position)
	print("未找到敌人名称: ", name)
	return null

# 随机创建敌人
func create_random_enemy(position: Vector2, level: int = 1) -> Enemy:
	if enemy_data_cache.is_empty():
		return null
	
	# 根据等级过滤敌人
	var available_enemies = []
	for data in enemy_data_cache.values():
		# 这里可以根据等级决定哪些敌人可以出现
		available_enemies.append(data)
	
	if available_enemies.is_empty():
		return null
	
	var random_data = available_enemies[randi() % available_enemies.size()]
	var enemy = create_enemy(random_data, position)
	
	# 根据等级调整属性
	if level > 1:
		var health_multiplier = 1.0 + (level - 1) * 0.2
		if enemy.health_component:
			enemy.health_component.max_health = random_data.max_health * health_multiplier
			enemy.health_component.current_health = enemy.health_component.max_health
	
	return enemy

# 设置视觉
func setup_visual(enemy: Enemy, data: EnemyData) -> void:
	var sprite: Sprite2D
	
	if data.animation_frames:
		var animated_sprite = AnimatedSprite2D.new()
		animated_sprite.sprite_frames = data.animation_frames
		animated_sprite.play("idle")
		sprite = animated_sprite
	else:
		sprite = Sprite2D.new()
	
	if data.texture:
		sprite.texture = data.texture
	else:
		# 创建默认纹理
		sprite.texture = create_default_texture(data.modulate_color)
	
	sprite.scale = data.scale
	sprite.modulate = data.modulate_color
	enemy.add_child(sprite)

# 设置碰撞体
func setup_collision(enemy: Enemy, data: EnemyData) -> void:
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	
	var sprite_size = Vector2(32, 32)
	if data.texture:
		sprite_size = data.texture.get_size() * data.scale
	
	shape.size = sprite_size
	collision.shape = shape
	enemy.add_child(collision)

# 设置移动
func setup_movement(enemy: Enemy, data: EnemyData) -> void:
	var move = MoveComponent.new()
	move.speed = data.move_speed
	move.set_direction(Vector2.LEFT)  # 默认向左移动
	enemy.add_child(move)

# 设置攻击
func setup_attack(enemy: Enemy, data: EnemyData) -> void:
	match data.attack_type:
		"melee":
			var melee = MeleeAttack.new()
			melee.damage = data.attack_damage
			melee.attack_range = data.attack_range
			melee.attack_cooldown = data.attack_cooldown
			enemy.add_child(melee)
		
		"ranged":
			var ranged = RangedAttack.new()
			ranged.damage = data.attack_damage
			ranged.attack_range = data.attack_range
			ranged.attack_cooldown = data.attack_cooldown
			ranged.ammo_scene = data.projectile_scene
			ranged.ammo_speed = data.projectile_speed
			
			# 添加发射点
			var shoot_point = Marker2D.new()
			shoot_point.position = Vector2(20, 0)
			enemy.add_child(shoot_point)
			ranged.shoot_point = shoot_point
			
			enemy.add_child(ranged)

# 设置生命值
func setup_health(enemy: Enemy, data: EnemyData) -> void:
	var health = HealthComponent.new()
	health.max_health = data.max_health
	enemy.add_child(health)

# 设置自带效果
func setup_innate_effects(enemy: Enemy, data: EnemyData) -> void:
	for effect_data in data.innate_effects:
		var effect = effect_data.create_effect()
		if effect:
			enemy.add_status_effect(effect)

# 创建默认纹理
func create_default_texture(color: Color) -> Texture2D:
	var size = 32
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

# 获取所有敌人ID
func get_all_enemy_ids() -> Array:
	return enemy_data_cache.keys()

# 获取所有敌人名称
func get_all_enemy_names() -> Array:
	var names = []
	for data in enemy_data_cache.values():
		names.append(data.enemy_name)
	return names

# 获取敌人数据
func get_enemy_data(enemy_id: String) -> EnemyData:
	return enemy_data_cache.get(enemy_id)
