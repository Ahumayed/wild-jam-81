class_name HealthComponent
extends Node

signal health_changed(prev_health: float, new_health: float)
signal died

@export var max_health: float = 100.0

var health: float = max_health:
	set(value):
		if value <= 0:
			died.emit()	
		health_changed.emit(health, value)	
		health = value
			
