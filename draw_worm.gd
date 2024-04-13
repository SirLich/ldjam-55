@tool
extends Node2D

func _draw():
	draw_circle(Vector2(0,0), 100, Color.RED)
	
func _process(delta):
	queue_redraw()
