extends Node2D
class_name ExplosionComponent

# 爆炸参数
@export var explosion_radius: float = 100.0
@export var explosion_damage: float = 50.0
@export var damage_falloff: bool = true
@export var knockback_force: float = 300.0

# 视觉效果
@export var explosion_texture: Texture2D
@export var explosion_scale: Vector2 = Vector2(2, 2)
@export var explosion_animation_duration: float = 0.5

# 特效
@export var particle_scene: PackedScene
@export var shake_intensity: float = 10.0
@export var shake_duration: float = 0.2

# 音效
@export var explosion_sound: AudioStream

# 效果颜色映射
var effect_colors: Dictionary = {
	"fire": Color(1.0, 0.3, 0.0, 1.0),      # 橙色
	"ice": Color(0.3, 0.6, 1.0, 1.0),       # 冰蓝色
	"poison": Color(0.3, 0.8, 0.2, 1.0),    # 绿色
	"stun": Color(1.0, 1.0, 0.0, 1.0),      # 黄色
	"normal": Color(1.0, 1.0, 1.0, 1.0)     # 白色
}

# 内部变量
var is_exploding: bool = false
var explosion_center: Vector2 = Vector2.ZERO
var explosion_timer: float = 0.0
var source_damage: float = 0.0
var source_effect_type: String = ""
var source_effect_duration: float = 0.0
var source_effect_strength: float = 0.0
var explosion_color: Color = Color.WHITE

# 信号
signal explosion_started(position: Vector2, radius: float)
signal explosion_finished()
signal damage_dealt(target: Node2D, damage: float)

func _ready():
	if not explosion_texture:
		explosion_texture = create_default_explosion_texture()

# 触发爆炸
func explode(center: Vector2, damage: float, effect_type: String = "", effect_duration: float = 0.0, effect_strength: float = 0.0) -> void:
	if is_exploding:
		return
	
	explosion_center = center
	source_damage = damage
	source_effect_type = effect_type
	source_effect_duration = effect_duration
	source_effect_strength = effect_strength
	
	# 根据效果类型设置爆炸颜色
	if effect_type == "" or effect_type == "normal":
		explosion_color = effect_colors["normal"]
	else:
		explosion_color = effect_colors.get(effect_type, effect_colors["normal"])
	
	is_exploding = true
	explosion_timer = 0.0
	
	# 播放视觉特效（传入半径和颜色）
	play_explosion_visual(center, explosion_radius, explosion_color)
	
	# 播放音效
	play_explosion_sound()
	
	# 屏幕震动（根据爆炸半径调整强度）
	var actual_shake = shake_intensity * (explosion_radius / 100.0)
	shake_camera(actual_shake)
	
	# 造成伤害并施加效果
	deal_damage_and_effects(center)
	
	# 发射开始信号
	explosion_started.emit(center, explosion_radius)
	
	print("爆炸发生！位置: ", center, " 半径: ", explosion_radius, " 伤害: ", damage, " 效果: ", effect_type, " 颜色: ", explosion_color)

func _process(delta):
	if not is_exploding:
		return
	
	explosion_timer += delta
	if explosion_timer >= explosion_animation_duration:
		is_exploding = false
		explosion_finished.emit()
		queue_free()

# 造成伤害并施加效果
func deal_damage_and_effects(center: Vector2) -> void:
	# 获取爆炸范围内的所有敌人
	var enemies = get_tree().get_nodes_in_group("enemy")
	var affected_count = 0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		# 计算距离
		var distance = center.distance_to(enemy.global_position)
		
		if distance <= explosion_radius:
			affected_count += 1
			
			# 计算伤害（衰减）
			var damage = source_damage
			if damage_falloff and explosion_radius > 0:
				damage = source_damage * (1 - distance / explosion_radius)
				damage = max(1, damage)
			
			# 造成伤害
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage, "explosion")
				damage_dealt.emit(enemy, damage)
			
			# 施加效果
			apply_effect_to_target(enemy)
			
			# 击退效果（根据距离调整力度）
			apply_knockback(enemy, center, distance)
	
	print("爆炸影响了 ", affected_count, " 个敌人")

# 对目标施加效果
func apply_effect_to_target(target: Node2D) -> void:
	match source_effect_type:
		"fire":
			var burn = BurnEffect.new()
			burn.duration = source_effect_duration
			burn.damage_per_second = source_effect_strength
			target.add_status_effect(burn)
		
		"ice":
			var freeze = FreezeEffect.new()
			freeze.duration = source_effect_duration
			freeze.slow_percent = source_effect_strength
			target.add_status_effect(freeze)
		
		"poison":
			var poison = PoisonEffect.new()
			poison.duration = source_effect_duration
			poison.damage_per_second = source_effect_strength
			target.add_status_effect(poison)
		
		"stun":
			var stun = StunEffect.new()
			stun.stun_duration = source_effect_duration
			target.add_status_effect(stun)

# 应用击退
func apply_knockback(enemy: Node2D, center: Vector2, distance: float) -> void:
	if knockback_force <= 0:
		return
	
	var direction = (enemy.global_position - center).normalized()
	var force = knockback_force * (1 - distance / explosion_radius)
	
	if enemy.has_method("apply_knockback"):
		enemy.apply_knockback(direction * force)

# 播放爆炸视觉（只保留一个爆炸效果）
func play_explosion_visual(center: Vector2, radius: float, color: Color) -> void:
	# 创建爆炸精灵（主爆炸效果）
	var explosion_sprite = Sprite2D.new()
	explosion_sprite.texture = explosion_texture
	explosion_sprite.global_position = center
	explosion_sprite.modulate = color
	
	# 根据爆炸半径设置初始大小
	var initial_scale = radius / 64.0 * 0.5
	explosion_sprite.scale = Vector2(initial_scale, initial_scale)
	
	get_tree().current_scene.add_child(explosion_sprite)
	
	# 缩放动画（根据半径调整目标大小）
	var target_scale = explosion_scale * (radius / 100.0)
	var tween = create_tween()
	tween.tween_property(explosion_sprite, "scale", target_scale, explosion_animation_duration * 0.8).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(explosion_sprite, "modulate:a", 0, explosion_animation_duration)
	tween.tween_callback(explosion_sprite.queue_free)
	
	# 添加粒子效果（根据效果类型和半径调整）
	if particle_scene:
		var particles = particle_scene.instantiate()
		particles.global_position = center
		
		# 根据效果类型调整粒子颜色
		if particles is CPUParticles2D:
			particles.color = color
			# 根据爆炸半径调整粒子数量
			particles.amount = int(20 * (radius / 100.0))
			# 根据爆炸半径调整粒子范围
			particles.spread = 360.0 * (radius / 100.0)
		
		get_tree().current_scene.add_child(particles)
		
		var particle_timer = get_tree().create_timer(explosion_animation_duration)
		particle_timer.timeout.connect(particles.queue_free)

# 播放音效
func play_explosion_sound() -> void:
	if not explosion_sound:
		return
	
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = explosion_sound
	audio_player.global_position = explosion_center
	audio_player.autoplay = true
	
	# 根据爆炸半径调整音量
	audio_player.volume_db = linear_to_db(min(1.0, explosion_radius / 100.0))
	
	get_tree().current_scene.add_child(audio_player)
	
	var timer = get_tree().create_timer(explosion_sound.get_length())
	timer.timeout.connect(audio_player.queue_free)

# 屏幕震动
func shake_camera(intensity: float) -> void:
	if intensity <= 0:
		return
	
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var original_position = camera.position
	var tween = create_tween()
	
	var shake_count = max(5, int(10 * (intensity / 10.0)))
	for i in range(shake_count):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "position", original_position + offset, shake_duration / shake_count)
	
	tween.tween_property(camera, "position", original_position, shake_duration / shake_count)

func create_default_explosion_texture() -> Texture2D:
	var size = 64
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = size / 2
	var max_radius = size / 2
	
	for x in range(size):
		for y in range(size):
			var distance = Vector2(x - center, y - center).length()
			if distance <= max_radius:
				var alpha = 1.0 - (distance / max_radius) * 0.5
				var brightness = 1.0 - (distance / max_radius) * 0.3
				var color = Color(1.0, brightness * 0.5, 0.2, alpha)
				image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)
