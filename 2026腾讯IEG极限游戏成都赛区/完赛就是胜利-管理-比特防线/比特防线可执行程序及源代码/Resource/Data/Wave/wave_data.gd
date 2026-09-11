extends Resource
class_name WaveData

@export var wave_number: int = 0
@export var enemy_spawns: Array[Dictionary] = []  # {"id": Array[Vector2]}
@export var spawn_interval: float = 2.0
