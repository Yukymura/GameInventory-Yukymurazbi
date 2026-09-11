extends Area2D

class_name Ammo

@export var speed: float = 1000.0
@export var damage: float = 5.0

@export var target_type: String = "enemy"

@onready var texture: Sprite2D = $Texture
@onready var move_component: MoveComponent = $MoveComponent

@export var ammo_texture_dictionary: Dictionary = {
	"normal": preload("uid://c7uwfqjnhdhvr"),
	"explosive": preload("uid://gsudg2vbiqny"),
	"ray": preload("uid://da0y2iy8p2fhy"),
	"enemy": preload("uid://c7uwfqjnhdhvr"),
}

var direction: Vector2 = Vector2.RIGHT
var ammo_type: String = "normal"
var effect_type: String = "normal"  # normal, fire, ice, poison, stun
var effect_duration: float = 2.0
var effect_strength: float = 0.5

# 爆炸属性
var explosion_radius: float = 150.0
var explosion_knockback: float = 300.0
var explosion_damage_falloff: bool = true

# 内部变量
var has_exploded: bool = false

func _ready() -> void:
	add_to_group("ammo")
	area_entered.connect(on_enemy_entered)
	move_component.set_speed(speed)
	move_component.set_direction(direction)

func set_direction(dir: Vector2) -> void:
	await ready
	move_component.set_direction(dir)
	look_at(global_position + dir)

func set_s_d(s: float, d: float) -> void:
	speed = s
	damage = d

func load_texture() -> void:
	await ready
	texture.texture = ammo_texture_dictionary[ammo_type]
	match ammo_type:
		"explosive":
			scale = Vector2(1.2, 1.2)
		"enemy":
			texture.modulate = Color.RED
	match effect_type:
		"ice":
			texture.modulate = Color.BLUE
		"fire":
			texture.modulate = Color.ORANGE

# 设置爆炸参数
func set_explosive(radius: float = 30.0, knockback: float = 300.0, falloff: bool = true) -> void:
	explosion_radius = radius
	explosion_knockback = knockback
	explosion_damage_falloff = falloff

# 敌人进入区域
func on_enemy_entered(area) -> void:
	if not area.is_in_group(target_type):
		return
	
	match ammo_type:
		"normal", "enemy":
			SignalBus.play_sfx.emit("hit_1")
		"explosive":
			SignalBus.play_sfx.emit("hit_2")
		"ray":
			SignalBus.play_sfx.emit("hit_3")
	
	# 判断是否是爆炸弹药
	if ammo_type == "explosive" and not has_exploded:
		# 触发爆炸
		trigger_explosion(area)
	else:
		# 普通弹药：只伤害单个敌人
		deal_damage_to_single_target(area)
		queue_free()

# 触发爆炸
func trigger_explosion(hit_target: Node2D) -> void:
	has_exploded = true
	
	# 获取爆炸位置（子弹当前位置）
	var explosion_position = global_position
	
	# 创建爆炸效果组件
	var explosion = ExplosionComponent.new()
	explosion.explosion_radius = explosion_radius
	explosion.explosion_damage = damage
	explosion.damage_falloff = explosion_damage_falloff
	explosion.knockback_force = explosion_knockback
	
	# 传递效果信息
	explosion.source_effect_type = effect_type
	explosion.source_effect_duration = effect_duration
	explosion.source_effect_strength = effect_strength
	explosion.source_damage = damage
	
	# 添加爆炸组件到场景
	get_tree().current_scene.add_child(explosion)
	
	# 触发爆炸
	explosion.explode(explosion_position, damage, effect_type, effect_duration, effect_strength)
	
	# 立即销毁子弹
	queue_free()

# 对单个目标造成伤害
func deal_damage_to_single_target(target: Node2D) -> void:
	# 造成伤害
	var health = target.get("health_component")
	if health:
		health.take_damage(damage)
	
	# 施加效果
	apply_effect_to_target(target)

# 对目标施加效果
func apply_effect_to_target(target: Node2D) -> void:
	match effect_type:
		"fire":
			var burn = BurnEffect.new()
			burn.duration = effect_duration
			burn.damage_per_second = effect_strength
			target.add_status_effect(burn)
		
		"ice":
			var freeze = FreezeEffect.new()
			freeze.duration = effect_duration
			freeze.slow_percent = effect_strength
			target.add_status_effect(freeze)
		
		"poison":
			var poison = PoisonEffect.new()
			poison.duration = effect_duration
			poison.damage_per_second = effect_strength
			target.add_status_effect(poison)
		
		"stun":
			var stun = StunEffect.new()
			stun.stun_duration = effect_duration
			target.add_status_effect(stun)
