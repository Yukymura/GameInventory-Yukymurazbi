extends Control



func _ready() -> void:
	SignalBus.play_bg.emit("bg_1")
	
	$ExitButton.pressed.connect(func():
		get_tree().quit()
		)
	$StartButton.pressed.connect(func():
		get_tree().change_scene_to_packed(GlobalNode.MAIN)
		)
