extends Resource
class_name EffectData

@export var effect_name: String = "效果"
@export var effect_type: String = "slow"  # slow, burn, poison, stun, freeze
@export var duration: float = 3.0
@export var strength: float = 0.5  # 减速百分比、每秒伤害等
@export var is_stacking: bool = false
@export var max_stacks: int = 3
@export var visual_effect: PackedScene  # 视觉特效场景

# 创建实际的效果对象
func create_effect() -> StatusEffect:
	var effect: StatusEffect = null
	
	match effect_type:
		"slow":
			var slow = SlowEffect.new()
			slow.slow_percent = strength
			effect = slow
		"burn":
			var burn = BurnEffect.new()
			burn.damage_per_second = strength
			effect = burn
		"poison":
			var poison = PoisonEffect.new()
			poison.damage_per_second = strength
			effect = poison
		"stun":
			var stun = StunEffect.new()
			stun.stun_duration = strength
			effect = stun
		"freeze":
			var freeze = FreezeEffect.new()
			freeze.slow_percent = strength
			effect = freeze
	
	if effect:
		effect.effect_name = effect_name
		effect.duration = duration
		effect.is_stacking = is_stacking
		effect.max_stacks = max_stacks
	
	return effect
