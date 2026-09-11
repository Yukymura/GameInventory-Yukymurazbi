extends Node

signal create_damage_label_request(text: String, pos: Vector2)

signal wave_cleared()
signal game_over()
signal game_victory()

signal electricity_changed(value: int)
signal turret_range_changed(range: int)
signal turret_cooldown_changed(rate: float)
signal global_attribute_changed(attribute_name: String, value)
signal turret_attribute_changed(attribute_name: String, value)

signal play_sfx(sfx: String)
signal play_bg(bg: String)
