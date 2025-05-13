extends ProgressBar

func _ready() -> void:
	value = 100

func _on_health_component_health_changed(_prev_health: float, new_health: float) -> void:
	value = new_health	
