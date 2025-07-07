# Main.gd
extends Node2D

func _on_play_pressed():
	var game_scene = preload("res://scenes/game/game.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	get_tree().current_scene = game_scene
	queue_free()
