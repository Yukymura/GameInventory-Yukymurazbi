extends Node

@onready var global_node: Node = GlobalNode
@onready var electric_label: Label = $BottomPanel/InfoPanel/ElectricLabel
@onready var battle_panel: Node = $BattlePanel

@onready var next_wave_button: Button = $TopPanel/NextWaveButton
@onready var setting_button: TextureButton = $TopPanel/SettingButton
@onready var tree_button: TextureButton = $TopPanel/TreeButton

func _ready() -> void:
	SignalBus.play_bg.emit("bg_2")
	
	global_node.init_all_attribute()
	
	electric_label.text = str(global_node.electricity)
	
	SignalBus.electricity_changed.connect(func(value: int):
		electric_label.text = str(value)
		)
	SignalBus.wave_cleared.connect(func():
		next_wave_button.disabled = false
		next_wave_button.text = "下一波(第" + str(global_node.current_wave) +"波)"
		)
	tree_button.pressed.connect(func():
		$TalentTree.show()
		)
	$ExitPanel/Button.pressed.connect(func():
		$ExitPanel.queue_free()
	)
	$EndPanel/Button.pressed.connect(func():
		get_tree().change_scene_to_packed(GlobalNode.START_SCENE)
		)
	next_wave_button.pressed.connect(on_next_wave_button_pressed)
	SignalBus.game_over.connect(
		$EndPanel.show
	)
	SignalBus.game_victory.connect(
		$EndPanel.show
	)
	
	AudioManager.bind_ui_sfx(self)

func on_next_wave_button_pressed() -> void:
	next_wave_button.disabled = true
	battle_panel.spawn_wave(global_node.current_wave)
	global_node.current_wave += 1
