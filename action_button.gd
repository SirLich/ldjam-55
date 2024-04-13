extends Button

@export_enum("MOVE", "EXPLODE") var action : String

func _on_pressed():
	get_tree().get_first_node_in_group("player").set_action(action)
