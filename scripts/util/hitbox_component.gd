class_name HitboxComponent
extends Area2D

signal hit(hurtbox: HurtboxComponent)

@export var damage: float = 1.0

func _process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if area is HurtboxComponent:
			var hurtbox := area as HurtboxComponent
			if hurtbox.damage(damage):
				hit.emit(hurtbox)
