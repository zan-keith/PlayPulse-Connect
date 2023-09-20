extends Control


func _ready():
	$AnimationPlayer.play("startup")



func _on_Panel_gui_input(event):
	$AnimationPlayer.play("startup")



	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://Scenes/Pages/WelcomeScreen.tscn")
