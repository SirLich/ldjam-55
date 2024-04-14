extends Sprite2D

func go_red():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.5)
	await tween.finished
	go_white()
	
func go_white():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	await tween.finished
	go_red()
	
func _ready():
	go_red()
