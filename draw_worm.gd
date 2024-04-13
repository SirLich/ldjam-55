@tool
extends Node2D

func _draw():
	draw_circle(Vector2(0,0), 10, Color.BLACK)
	draw_circle(Vector2(100, 100) - global_position, 15, Color.BLUE)
	
func _process(delta):
	queue_redraw()
