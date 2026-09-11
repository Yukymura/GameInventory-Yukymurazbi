extends AttackComponent
class_name RangedAttack

# 远程特有属性
@export var ammo_scene: PackedScene  # 子弹场景
@export var ammo_speed: float = 200.0
@export var shoot_point: Marker2D = null  # 发射点

func try_attack(target: Node2D) -> void:
	if not target or not is_instance_valid(target):
		return
	# 检查距离
	#var distance = parent.global_position.distance_to(target.global_position)
	#if distance <= attack_range and can_attack:
	if can_attack:
		shoot_ammo(target)

func shoot_ammo(target: Node2D) -> void:
	can_attack = false
	
	# 创建子弹
	if ammo_scene:
		var ammo: Ammo = ammo_scene.instantiate()

		# 设置发射位置
		if shoot_point:
			ammo.global_position = shoot_point.global_position
		else:
			ammo.global_position = parent.global_position
		ammo.set_direction(Vector2(ammo.global_position.direction_to(target.global_position).x, 0.))
		
		ammo.target_type = "base"
		ammo.ammo_type = "enemy"
		ammo.set_s_d(ammo_speed, damage)
		ammo.load_texture()
		get_tree().current_scene.add_child(ammo)
		
	attack_performed.emit(target, damage)

# 设置发射点
func set_shoot_point(point: Marker2D) -> void:
	shoot_point = point
