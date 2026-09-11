extends Area2D

class_name Base

@onready var health_component: HealthComponent = $HealthComponent
@onready var progress_bar: TextureProgressBar = $ProgressBar

func _ready() -> void:
	add_to_group("base")
	
	health_component.health_changed.connect(set_progress_value)
	progress_bar.max_value = health_component.max_health

func on_died():
	SignalBus.game_over.emit()

func set_progress_value(v: float, max_v: int) -> void:
	progress_bar.max_value = max_v
	progress_bar.value = v
