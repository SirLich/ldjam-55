extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		AudioBus.get_child(0).play()
		body.heal(10)
		
		queue_free()


