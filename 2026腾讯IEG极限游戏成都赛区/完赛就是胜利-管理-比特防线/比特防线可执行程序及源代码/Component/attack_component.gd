extends Node
class_name AttackComponent

# 攻击属性
@export var damage: float = 10.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0

# 内部变量
var can_attack: bool = true
var attack_timer: float = 0.0
var parent = null

# 信号
signal attack_performed(target: Node2D, damage: float)

func _ready():
	parent = get_parent()
	if not parent:
		printerr("AttackComponent需要挂在节点上")

func _process(delta):
	if not can_attack:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			can_attack = true
			attack_timer = 0.0

# 尝试攻击（子类实现）
func try_attack(_target: Node2D) -> void:
	pass

# 执行攻击
func perform_attack(target: Node2D) -> void:
	if not can_attack:
		return
	
	can_attack = false
	
	# 造成伤害
	var h = target.get("health_component")
	if h:
		h.take_damage(damage)
	
	attack_performed.emit(target, damage)
