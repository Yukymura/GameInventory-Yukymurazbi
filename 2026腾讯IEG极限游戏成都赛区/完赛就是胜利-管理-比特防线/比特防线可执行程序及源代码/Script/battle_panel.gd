extends Node2D

const ENEMY = preload("uid://bd1r1a0v1027m")
const DAMAGE_LABEL = preload("uid://doycltkntynl")
const AMMO = preload("uid://c1mwciudtssiu")

@onready var global_node: Node = GlobalNode
@onready var spawner: Node = $Spawner
@onready var enemies: Node2D = $Enemies
@onready var labels: Node2D = $Labels
@onready var turrets: Node2D = $Turrets
@onready var spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	# 信号连接
	SignalBus.create_damage_label_request.connect(create_damage_label)
	enemies.child_order_changed.connect(check_enemy_num)
	$Area.area_exited.connect(clear_ammo)
	
	for t in range(5):
		add_ammo_to_turret(t, "无", "无", 10)

func check_enemy_num() -> void:
	if enemies.get_child_count() == 0:
		SignalBus.wave_cleared.emit()

func spawn_wave(wave_index: int = 0) -> void:
	var e_arr = spawner.get_enemy_wave(wave_index)
	for e in e_arr:
		enemies.add_child(e)

func add_ammo_to_turret(turret_index: int, ammo_type: String, ammo_effect: String, num: int = 1) -> void:
	for i in range(num):
		var t := turrets.get_child(turret_index)
		var ammo := AMMO.instantiate()
		ammo.ammo_type = type_name_to_type(ammo_type)
		ammo.effect_type = effect_name_to_effect(ammo_effect)
		
		var speed_rate: float = global_node.ammo_speed_extra_rate + 1.
		var damage_rate: float = global_node.damage_extra_rate + 1.
		match ammo.ammo_type:
			"normal":
				ammo.set_s_d(250 * speed_rate, 20 * damage_rate)
			"explosive":
				ammo.set_s_d(200 * speed_rate, 20 * damage_rate)
				ammo.set_explosive(50.0, 30.0, true)
			"ray":
				ammo.set_s_d(500 * speed_rate, 80 * damage_rate)
		
		ammo.load_texture()
		t.add_ammo_to_array(ammo)

func create_damage_label(text: String, pos: Vector2) -> void:
	var label = DAMAGE_LABEL.instantiate()
	label.set_text(text)
	label.position = pos
	labels.add_child(label)

# 清除范围外的子弹
func clear_ammo(ammo) -> void:
	if ammo.is_in_group("ammo"):
		ammo.queue_free()

func on_enemy_cleared() -> void:
	SignalBus.wave_cleared.emit()

func type_name_to_type(type_name: String) -> String:
	match type_name:
		"无":
			return "normal"
		"机枪子弹":
			return "normal"
		"榴弹炮弹":
			return "explosive"
		"激光枪能量弹":
			return "ray"
	return ""

func effect_name_to_effect(effect_name: String) -> String:
	match effect_name:
		"无":
			return "normal"
		"燃烧":
			return "fire"
		"脉冲":
			return "stun"
		"冰冻":
			return "ice"
	return ""


func _on_build_and_reward_to_tower(row: int, type: String, magic: String) -> void:
	pass # Replace with function body.
