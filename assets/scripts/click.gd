extends Area2D

signal clicked

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		emit_signal("clicked")
		get_parent().modulate.a = 0.25

func _ready():
	connect("mouse_entered", self, "on_mouse_entered")
	connect("mouse_exited", self, "on_mouse_exited")

func on_mouse_entered():
	get_parent().modulate.a = 0.5

func on_mouse_exited():
	get_parent().modulate.a = 1.0
