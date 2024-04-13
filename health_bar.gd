extends ProgressBar

func _process(delta):
	var player : Player = get_tree().get_first_node_in_group("player")
	value = float(player.health) / float(player.max_health) * 100
