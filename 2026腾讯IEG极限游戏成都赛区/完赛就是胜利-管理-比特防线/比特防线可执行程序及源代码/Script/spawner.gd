extends Node
class_name Spawner

@onready var enemy_factory: EnemyFactory = $EnemyFactory

@export var spawn_points: Array[Marker2D] = []
@export var wave_configs: Dictionary = {
	0: preload("uid://bmxg0gb5dm6rd"),
	1: preload("uid://cm6bgqrraqiwp"),
	2: preload("uid://cvngmle8jakep"),
	3: preload("uid://c427xet4qeyo"),
	4: preload("uid://ckcy54hsbebk2"),
	5: preload("uid://b2c24hmwmo2w8"),
	6: preload("uid://d23tm2uymcg8j")
}

var spawn_timer: float = 0.0
var current_wave_index: int = 0
var enemies_to_spawn: Array[EnemyData] = []
var is_spawning: bool = false

func get_enemy_wave(level: int) -> Array:
	var wave = wave_configs.get(level)
	if not wave:
		return []
	
	var enemies: Array = []
	var e = wave.enemy_spawns.pick_random()
	for id in e:
		var pos_arr = e[id]
		for pos in pos_arr:
			enemies.append(enemy_factory.create_enemy_by_id(id, pos))
	
	return enemies
