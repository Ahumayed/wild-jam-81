class_name HurtboxComponent
extends Area2D

@onready var iframe_timer: Timer

signal damaged(amount: float)

func damage(amount: float) -> bool:
	if iframe_timer.is_stopped():
		damaged.emit(amount)
		iframe_timer.start()
		return true
	return false
