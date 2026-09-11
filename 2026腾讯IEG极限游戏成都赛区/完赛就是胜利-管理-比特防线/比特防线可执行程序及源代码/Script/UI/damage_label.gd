extends Control

@onready var label: Label = $Label

func _ready() -> void:
	animation()
	rotation_degrees = randf_range(-15., 15.)

func set_text(text: String) -> void:
	await ready
	label.text = text

func animation() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(sin(rotation), -cos(rotation)) * 4, .2).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free).set_delay(.5)
