extends Node2D

@export var spawn_scene : PackedScene

func random_spawn_point():
	var rect : Rect2 = get_viewport().get_visible_rect()
	return Vector2(randf_range(rect.position.x, rect.end.x), randf_range(rect.position.y, rect.end.y))
	
func _on_spawn_timer_timeout():
	var new_enemy = spawn_scene.instantiate()
	new_enemy.global_position = random_spawn_point()
	add_child(new_enemy)
	
