@tool
extends Node2D

func _draw():
	draw_circle(Vector2(0,0), 10, Color.BLACK)
	
func _process(delta):
	queue_redraw()
