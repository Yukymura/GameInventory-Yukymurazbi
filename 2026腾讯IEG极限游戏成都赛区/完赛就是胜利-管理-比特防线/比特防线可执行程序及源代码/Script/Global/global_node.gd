# 全局节点

extends Node

const MAIN = preload("uid://bvdfti6cpqld7")
const START_SCENE = preload("uid://dgaomb7iah348")

var wave_bonus: Dictionary = {
	0: 100,
	1: 450,
	2: 550,
	3: 700,
	4: 900,
	5: 1000,
	6: 1000,
	7: 0,
}
var current_wave: int = 0

var base_max_health: int:
	set(v):
		var base = get_tree().get_first_node_in_group("base")
		if base:
			base.health_component.set_max_health(v)
			base.health_component.reset()
		base_max_health = v

var electricity: int = 10:
	set(v):
		if electricity != v:
			SignalBus.play_sfx.emit("electric")
			SignalBus.electricity_changed.emit(v)
		electricity = v

var ammo_speed_extra_rate: float
var damage_extra_rate: float
var turret_cooldown_extra_rate: float:
	set(v):
		if not turret_cooldown_extra_rate == v:
			SignalBus.turret_cooldown_changed.emit(v)
		turret_cooldown_extra_rate = v
var resorce_collect_extra_rate: float
var turret_range: int = 150:
	set(v):
		if not turret_range == v:
			SignalBus.turret_range_changed.emit(v)
		turret_range = v

func _ready() -> void:
	SignalBus.wave_cleared.connect(on_wave_end)

func add_attribute(a_dict: Dictionary) -> void:
	for attribute in a_dict:
		var v = get(attribute)
		if not v == null:
			set(attribute, v + a_dict[attribute])
			print("属性" + attribute + "增加" + str(a_dict[attribute]))

func init_all_attribute() -> void:
	base_max_health = 10000
	electricity = 10
	
	ammo_speed_extra_rate = 0.
	damage_extra_rate = 0.
	turret_cooldown_extra_rate = 0.
	resorce_collect_extra_rate = 0.
	turret_range = 150

func on_wave_end() -> void:
	if current_wave == 7:
		SignalBus.game_victory.emit()
	electricity += wave_bonus[current_wave - 1]
