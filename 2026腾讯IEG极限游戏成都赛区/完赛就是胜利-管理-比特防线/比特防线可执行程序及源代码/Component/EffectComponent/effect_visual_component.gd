extends Node2D
class_name EffectVisualComponent

# 视觉特效
var active_effects: Dictionary = {}  # 效果名称 -> 视觉节点
var effect_colors: Dictionary = {
	"slow": Color(0.3, 0.5, 0.8, 0.6),
	"burn": Color(1.0, 0.3, 0.0, 0.7),
	"poison": Color(0.3, 0.8, 0.2, 0.6),
	"stun": Color(1.0, 1.0, 0.0, 0.8),
	"freeze": Color(0.3, 0.6, 1.0, 0.7)
}

# 存储颜色恢复定时器
var color_timers: Dictionary = {}
var parent_enemy: Node2D = null

func _ready():
	parent_enemy = get_parent()
	print("EffectVisualComponent 已创建，父节点: ", parent_enemy.name if parent_enemy else "null")

func add_effect_visual(effect_name: String, duration: float) -> void:
	print("添加视觉效果: ", effect_name, " 持续时间: ", duration)
	
	# 如果效果已经存在，刷新持续时间
	if active_effects.has(effect_name):
		var visual = active_effects[effect_name]
		if visual and is_instance_valid(visual) and visual.has_method("refresh"):
			visual.refresh(duration)
		return
	
	# 创建视觉特效
	var visual = create_visual_effect(effect_name)
	if visual:
		active_effects[effect_name] = visual
		add_child(visual)
		
		# 设置自动移除
		var timer = get_tree().create_timer(duration)
		timer.timeout.connect(func(): remove_effect_visual(effect_name))
		print("视觉效果已添加: ", effect_name)
	else:
		print("创建视觉效果失败: ", effect_name)
	
	# 应用颜色变化
	apply_effect_color(effect_name, duration)

func remove_effect_visual(effect_name: String) -> void:
	print("移除视觉效果: ", effect_name)
	
	if active_effects.has(effect_name):
		var visual = active_effects[effect_name]
		if visual and is_instance_valid(visual):
			visual.queue_free()
		active_effects.erase(effect_name)

func create_visual_effect(effect_name: String) -> Node2D:
	var visual: Node2D = null
	
	match effect_name:
		"slow":
			visual = create_slow_effect()
		"burn":
			visual = create_burn_effect()
		"poison":
			visual = create_poison_effect()
		"stun":
			visual = create_stun_effect()
		"freeze":
			visual = create_freeze_effect()
	
	return visual

func create_slow_effect() -> Node2D:
	var effect = Node2D.new()
	
	# 添加光环效果
	var aura = create_aura_effect(effect_colors["slow"])
	effect.add_child(aura)
	
	# 添加精灵效果
	var sprite = Sprite2D.new()
	sprite.texture = create_circle_texture(8, effect_colors["slow"])
	sprite.modulate.a = 0.5
	effect.add_child(sprite)
	
	return effect

func create_burn_effect() -> Node2D:
	var effect = Node2D.new()
	
	# 火焰粒子效果
	var particles = create_fire_particles()
	effect.add_child(particles)
	
	# 红色光环
	var aura = create_aura_effect(effect_colors["burn"])
	effect.add_child(aura)
	
	return effect

func create_poison_effect() -> Node2D:
	var effect = Node2D.new()
	
	# 绿色粒子效果
	var particles = create_poison_particles()
	effect.add_child(particles)
	
	# 绿色光环
	var aura = create_aura_effect(effect_colors["poison"])
	effect.add_child(aura)
	
	return effect

func create_stun_effect() -> Node2D:
	var effect = Node2D.new()
	
	# 眩晕星星效果
	for i in range(3):
		var star = Sprite2D.new()
		star.texture = create_star_texture(16, effect_colors["stun"])
		star.position = Vector2(randf_range(-20, 20), randf_range(-30, 0))
		star.modulate.a = 0.8
		effect.add_child(star)
		
		# 旋转动画
		var tween = create_tween().set_loops(10)
		tween.tween_property(star, "rotation", TAU, 0.5)
	
	return effect

func create_freeze_effect() -> Node2D:
	var effect = Node2D.new()
	
	# 冰晶粒子效果
	var particles = create_freeze_particles()
	effect.add_child(particles)
	
	# 冰蓝色光环
	var aura = create_aura_effect(effect_colors["freeze"])
	effect.add_child(aura)
	
	# 添加冰晶环绕精灵
	for i in range(4):
		var ice = Sprite2D.new()
		ice.texture = create_ice_crystal_texture(12)
		var angle = i * PI * 2 / 4
		var radius = 25
		ice.position = Vector2(cos(angle) * radius, sin(angle) * radius)
		ice.modulate = effect_colors["freeze"]
		ice.modulate.a = 0.7
		effect.add_child(ice)
		
		# 旋转动画
		var tween = create_tween().set_loops(10)
		tween.tween_property(ice, "rotation", TAU, 2.0)
	
	return effect

func create_aura_effect(color: Color) -> Node2D:
	var aura = Sprite2D.new()
	aura.texture = create_circle_texture(10, color)
	aura.modulate.a = 0.3
	
	# 缩放动画
	var tween = create_tween()
	tween.tween_property(aura, "scale", Vector2(1.2, 1.2), 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(aura, "scale", Vector2(0.8, 0.8), 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops(100)
	
	return aura

func create_circle_texture(radius: int, color: Color) -> Texture2D:
	var image = Image.create(radius * 2, radius * 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	for x in range(radius * 2):
		for y in range(radius * 2):
			var distance = Vector2(x - radius, y - radius).length()
			if distance <= radius:
				var alpha = 1.0 - (distance / radius) * 0.7
				image.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
	
	return ImageTexture.create_from_image(image)

func create_star_texture(size: int, color: Color) -> Texture2D:
	var image = Image.create(size * 2, size * 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = size
	for i in range(5):
		var angle = i * 2 * PI / 5 - PI / 2
		var x = center + cos(angle) * size
		var y = center + sin(angle) * size
		image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)

func create_ice_crystal_texture(size: int) -> Texture2D:
	var image = Image.create(size * 2, size * 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = size
	# 绘制简单的冰晶形状（十字形）
	for i in range(4):
		var angle = i * PI / 2
		var x = center + cos(angle) * size * 0.8
		var y = center + sin(angle) * size * 0.8
		image.set_pixel(x, y, Color(0.8, 0.9, 1.0, 1.0))
	
	return ImageTexture.create_from_image(image)

func create_fire_particles() -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 20
	particles.lifetime = 0.5
	particles.speed_scale = 0.5
	particles.direction = Vector2(0, -1)
	particles.spread = 180
	particles.gravity = Vector2(0, 50)
	particles.color = Color(1, 0.5, 0)
	return particles

func create_poison_particles() -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 15
	particles.lifetime = 0.8
	particles.speed_scale = 0.3
	particles.direction = Vector2(0, 0)
	particles.spread = 360
	particles.color = Color(0.3, 0.8, 0.2)
	return particles

func create_freeze_particles() -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 25
	particles.lifetime = 0.6
	particles.speed_scale = 0.4
	particles.direction = Vector2(0, -1)
	particles.spread = 360
	particles.gravity = Vector2(0, 30)
	particles.color = Color(0.5, 0.8, 1.0, 0.8)
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.8
	
	# 创建冰晶粒子纹理
	var particle_texture = create_ice_crystal_texture(4)
	particles.texture = particle_texture
	
	return particles

# 应用效果颜色变化 - 修复版本
func apply_effect_color(effect_name: String, duration: float) -> void:
	if not parent_enemy:
		return
	
	var sprite = parent_enemy.get_node_or_null("Texture")
	if not sprite:
		print("未找到 Sprite2D 节点")
		return
	
	var original_color = Color(1, 1, 1, 1)
	
	match effect_name:
		"slow":
			sprite.modulate = Color(0.5, 0.5, 0.8, 1.0)
		"burn":
			sprite.modulate = Color(1.0, 0.5, 0.3, 1.0)
		"poison":
			sprite.modulate = Color(0.3, 0.8, 0.3, 1.0)
		"stun":
			sprite.modulate = Color(1.0, 1.0, 0.5, 1.0)
		"freeze":
			sprite.modulate = Color(0.5, 0.7, 1.0, 1.0)
	
	print("应用颜色变化: ", effect_name, " 颜色: ", sprite.modulate)
	
	# 清除旧的定时器
	if color_timers.has(effect_name):
		var old_timer = color_timers[effect_name]
		if old_timer and is_instance_valid(old_timer):
			# 直接停止并释放定时器，不需要 disconnect_all
			old_timer.stop()
			old_timer.queue_free()
		color_timers.erase(effect_name)
	
	# 创建新定时器恢复颜色
	var timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true
	
	# 创建恢复颜色的回调
	var restore_color = func():
		if sprite and is_instance_valid(sprite):
			sprite.modulate = original_color
			print("恢复颜色: ", effect_name)
		if color_timers.has(effect_name):
			color_timers.erase(effect_name)
		if timer and is_instance_valid(timer):
			timer.queue_free()
	
	timer.timeout.connect(restore_color)
	
	parent_enemy.add_child(timer)
	timer.start()
	color_timers[effect_name] = timer
