extends Node

@export var max_bg_player_num: int = 1
@export var max_sfx_player_num: int = 6

@onready var sfx: Node = $SFX
@onready var bg: Node = $BG

var bg_players: Array[AudioStreamPlayer] = []
var sfx_players: Array[AudioStreamPlayer] = []

var bg_dict: Dictionary = {
	"bg_1": preload("uid://vlesmfsiocbf"),
	"bg_2": preload("uid://67gynltxn0t8"),
	"bg_3": preload("uid://yqqtvwbsteod"),
}
var sfx_dict: Dictionary = {
	"button": preload("uid://dasfjwp2oq1ad"),
	"upgrade": preload("uid://cbey0152k83p"),
	"shoot": preload("uid://dy5dne50kjgka"),
	"pick": preload("uid://dp8kt46ah0e02"),
	"put": preload("uid://m5d5i7kd64r3"),
	"electric": preload("uid://b1roylje4h1jc"),
	"hit_1": preload("uid://byejpnllug36g"),
	"hit_2": preload("uid://dnnthyr85ajva"),
	"hit_3": preload("uid://bv3curspe1i3r"),
	"death": preload("uid://clvhq3qpme86o"),
	"victory": preload("uid://b3p0bw0pn3qtv"),
	"defeat": preload("uid://dwsda1ohgb775"),
}

func _ready() -> void:
	init_bg_players()
	init_sfx_players()
	SignalBus.play_sfx.connect(play_sfx)
	SignalBus.play_bg.connect(play_bg)

#初始化音乐播放器
func init_bg_players() -> void:
	for i in range(max_bg_player_num):
		var bg_player := AudioStreamPlayer.new()
		bg_player.name = "BG_" + str(i)
		bg.add_child(bg_player)
		bg_players.append(bg_player)

#初始化音效播放器
func init_sfx_players() -> void:
	for i in range(max_sfx_player_num):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "BG_" + str(i)
		sfx.add_child(sfx_player)
		sfx_players.append(sfx_player)

#播放音乐
func play_bg(bg_name: String, index: int = 0) -> void:
	if not bg_dict.get(bg_name):
		push_error("无法找到音乐: %s" % bg_name)
		return
	if index >= max_bg_player_num:
		push_error("无法播放音乐: %s, 访问超限" % bg_name)
		return
	
	var bg_stream: AudioStream = bg_dict.get(bg_name)
	var player := bg_players[index]
	player.stream = bg_stream
	player.play()

#播放音效
func play_sfx(sfx_name: String) -> void:
	if not sfx_dict.get(sfx_name):
		push_error("无法找到音效: %s" % sfx_name)
		return
	
	var sfx_stream: AudioStream = sfx_dict.get(sfx_name)
	for i in range(max_sfx_player_num):
		var player := sfx_players[i]
		if not player.playing:
			player.stream = sfx_stream
			player.play()
			return


#绑定UI音效
func bind_ui_sfx(node) -> void:
	if node is Button or node is TextureButton:
		node.pressed.connect(play_sfx.bind("button"))
	for n in node.get_children():
		bind_ui_sfx(n)
