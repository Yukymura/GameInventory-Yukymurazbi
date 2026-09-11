extends Panel

@onready var electricity_label: Label = $Panel/ElectricityLabel
@onready var nodes: Control = $Nodes
@onready var connections: Node2D = $Connections


@export var node_scene: PackedScene
@export var line: PackedScene

# 天赋数据 - 全部存在 Dictionary 中
var talent_data = {
	"talent_1": {
		"name": "伤害+5%",
		"position": Vector2(30, 50),
		"cost": 50,
		"unlocked": false,
		"prerequisites": [],
		"attribute": {"damage_extra_rate": 0.05}
	},
	"talent_2": {
		"name": "攻击速度+5%",
		"position": Vector2(105, 50),
		"cost": 50,
		"unlocked": false,
		"prerequisites": [],
		"attribute": {"turret_cooldown_extra_rate": 0.05}
	},
	"talent_3": {
		"name": "子弹速度+20%",
		"position": Vector2(180, 50),
		"cost": 50,
		"unlocked": false,
		"prerequisites": [],
		"attribute": {"ammo_speed_extra_rate": 0.2}
	},
	"talent_4": {
		"name": "射程+10",
		"position": Vector2(255, 50),
		"cost": 50,
		"unlocked": false,
		"prerequisites": [],
		"attribute": {"turret_range": 10}
	},
	"talent_5": {
		"name": "伤害+10%",
		"position": Vector2(30, 100),
		"cost": 150,
		"unlocked": false,
		"prerequisites": ["talent_1"],
		"attribute": {"damage_extra_rate": 0.1}
	},
	"talent_6": {
		"name": "攻击速度+7%",
		"position": Vector2(105, 100),
		"cost": 150,
		"unlocked": false,
		"prerequisites": ["talent_2"],
		"attribute": {"turret_cooldown_extra_rate": 0.07}
	},
	"talent_7": {
		"name": "子弹速度+30%",
		"position": Vector2(180, 100),
		"cost": 100,
		"unlocked": false,
		"prerequisites": ["talent_3"],
		"attribute": {"ammo_speed_extra_rate": 0.3}
	},
	"talent_8": {
		"name": "射程+13",
		"position": Vector2(255, 100),
		"cost": 100,
		"unlocked": false,
		"prerequisites": ["talent_4"],
		"attribute": {"turret_range": 13}
	},
	"talent_9": {
		"name": "伤害+15%",
		"position": Vector2(30, 150),
		"cost": 500,
		"unlocked": false,
		"prerequisites": ["talent_5"],
		"attribute": {"damage_extra_rate": 0.15}
	},
	"talent_10": {
		"name": "攻击速度+13%",
		"position": Vector2(105, 150),
		"cost": 500,
		"unlocked": false,
		"prerequisites": ["talent_6"],
		"attribute": {"turret_cooldown_extra_rate": 0.13}
	},
	"talent_11": {
		"name": "子弹速度+50%",
		"position": Vector2(180, 150),
		"cost": 350,
		"unlocked": false,
		"prerequisites": ["talent_7"],
		"attribute": {"ammo_speed_extra_rate": 0.5}
	},
	"talent_12": {
		"name": "射程+17",
		"position": Vector2(255, 150),
		"cost": 350,
		"unlocked": false,
		"prerequisites": ["talent_8"],
		"attribute": {"turret_range": 17}
	},
}

var talent_buttons: Dictionary = {}

signal talent_unlocked(talent_id: String)

func _ready():
	# 创建天赋按钮
	var offset: Vector2 = Vector2(30, 10)
	for id in talent_data:
		var data = talent_data[id]
		var btn = node_scene.instantiate()
		btn.text = data["name"] + "\n" + str(data["cost"]) + "电力"
		btn.position = data["position"]
		btn.size = Vector2(40, 20)
		btn.pressed.connect(_on_talent_pressed.bind(id))
		nodes.add_child(btn)
		talent_buttons[id] = btn
		
		for req in data["prerequisites"]:
			var l: Line2D = line.instantiate()
			var pos: Array = [data["position"] + offset, talent_data[req]["position"] + offset]
			l.points = pos
			connections.add_child(l)
	
	SignalBus.electricity_changed.connect(func(v: int):
		electricity_label.text = str(v)
		)
	$BackButton.pressed.connect(_on_close_button_pressed)
	
	update_ui()


func _on_talent_pressed(id: String):
	var data = talent_data[id]
	
	# 检查是否已解锁
	if data["unlocked"]:
		return
	
	# 检查前置
	for prereq in data["prerequisites"]:
		if not talent_data[prereq]["unlocked"]:
			return
	
	# 检查电力
	if GlobalNode.electricity < data["cost"]:
		return
	
	# 解锁
	GlobalNode.electricity -= data["cost"]
	data["unlocked"] = true
	GlobalNode.add_attribute(data["attribute"])
	
	# 更新按钮
	var btn = talent_buttons[id]
	btn.text = data["name"] + "\n已解锁"
	btn.disabled = true
	
	# 发射信号
	talent_unlocked.emit(id)
	
	update_ui()

func update_ui():
	electricity_label.text = str(GlobalNode.electricity)
	
	# 更新按钮颜色
	for id in talent_data:
		var data = talent_data[id]
		var btn = talent_buttons[id]
		
		if data["unlocked"]:
			btn.modulate = Color(0.3, 0.8, 0.3)
		else:
			# 检查是否满足条件
			var can_unlock = true
			for prereq in data["prerequisites"]:
				if not talent_data[prereq]["unlocked"]:
					can_unlock = false
					break
			
			if can_unlock and GlobalNode.electricity >= data["cost"]:
				btn.modulate = Color(1, 1, 1)
			else:
				btn.modulate = Color(0.5, 0.5, 0.5)

func _on_close_button_pressed():
	hide()
