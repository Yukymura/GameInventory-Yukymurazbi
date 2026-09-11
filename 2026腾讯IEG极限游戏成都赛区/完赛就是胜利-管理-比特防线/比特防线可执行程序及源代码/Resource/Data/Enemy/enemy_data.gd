extends Resource
class_name EnemyData

@export_group("基础信息")
@export var enemy_id: String = "enemy_001"
@export var enemy_name: String = "普通敌人"
@export_enum("normal", "fast", "tank", "boss", "ranged") var enemy_type: String = "normal"
@export var description: String = ""

@export_group("视觉")
@export var texture: Texture2D = preload("uid://doddxaxbiov8d") # 敌人图片
@export var scale: Vector2 = Vector2(1, 1)
@export var modulate_color: Color = Color(1, 1, 1, 1)
@export var animation_frames: SpriteFrames  # 动画帧（可选）

@export_group("基础属性")
@export var max_health: float = 100.0
@export var move_speed: float = 20.0
@export var reward_gold: int = 50
@export var reward_exp: int = 10

@export_group("攻击属性")
@export_enum("melee", "ranged") var attack_type: String = "melee"
@export var attack_damage: float = 10.0
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0

@export_group("远程攻击")
@export var projectile_scene: PackedScene  # 子弹场景
@export var projectile_speed: float = 500.0

@export_group("自带效果")
@export var innate_effects: Array[EffectData] = []

@export_group("死亡效果")
@export var death_effect: PackedScene  # 死亡特效
@export var on_death_spawn: Array[DeathSpawn] = []  # 死亡后生成其他敌人

@export_group("掉落物")
@export var drop_items: Array[DropData] = []

@export_group("移动路径")
@export var use_path: bool = false
@export var path_points: Array[Vector2] = []

func _init():
	enemy_id = "enemy_" + str(randi() % 10000)

# 获取敌人信息
func get_info() -> Dictionary:
	return {
		"id": enemy_id,
		"name": enemy_name,
		"type": enemy_type,
		"health": max_health,
		"speed": move_speed,
		"reward": reward_gold,
		"description": description
	}
