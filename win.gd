extends Control

var can_go_on = false

func _input(event):
	if (event is InputEventMouseButton or event is InputEventKey) and can_go_on:
		get_tree().change_scene_to_file("res://main_menu.tscn")
	
func _on_timer_timeout():
	can_go_on = true
