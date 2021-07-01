extends Sprite

onready var video = $vidya
onready var speaker = $chr
onready var diag = $text
onready var boxer = $diagbox
onready var flagster = $flags
onready var swinfo = $switch_info
onready var audio = $player

# Filenames for static frames.
const scr_static = [
	"television",
	"ico_look",
	"cube_look",
	"freezer_closed",
	"freezer_open",
	"drawer_freezer_open",
	"drawer_freezer_closed",
	"cone_cap_look",
	"television_off"
]

const scr_fmv = [
	"cap_talk",
	"cone_cap_talk",
	"cone_talk",
	"cube_eva",
	"cube_talk",
	"ico_talk",
	
	"end",
	
	"freezer_close",
	"freezer_open",
	"television_shutoff",
	
	"trans_boombox_cone_cap",
	"trans_cone_cap_boombox",   
	"trans_cone_cap_drawer",    
	"trans_cone_cap_television",
	"trans_ico_cube",
	"trans_ico_television",
	"trans_television_cone_cap",
	"trans_cone_cap_televison", 
	"trans_cube_freezer_closed",
	"trans_cube_ico",
	"trans_cube_television",
	"trans_drawer_cone_cap",
	"trans_drawer_freezer_closed",
	"trans_drawer_freezer_open",
	"trans_freezer_closed_cube",
	"trans_freezer_closed_drawer",
	"trans_freezer_open_cube",
	"trans_freezer_open_drawer",
	"trans_television_ico",
	"trans_cube_freezer_open",
	"trans_television_off_cone_cap",
	"trans_television_off_ico",
	"trans_cone_cap_television_off",
	"trans_ico_television_off"
]

const scenes = [
	[16, 0, 28], # Television
	[15, 1, 14], # Icosahedron
	[19, 2, 18], # Cube
	[24, 3, 25], # Freezer
	[22, 5, 21], # Drawer
	[12, 7, 13] # Cone and Capsule
]

const dict_files = [
	"",
	"icosphere",
	"cube",
	"",
	"",
	"cone",
	"capsule"
]

# Dictionary text array.
var dict = {}
var rand_idx : String = "1"
var rand_chosen : bool = false

# For the final scene, is Cone or Capsule talking?
var diag_switch: bool = false

var visited = [
	false,
	false,
	false,
	false,
	false,
	false
]

# This variable indexes into the scenes array.
var scene_pos: int = 0

# Did the player open the freezer?
var freezer_open: bool = false

# Did the player turn off the TV?
var television_on: bool = true

# Is a FMV dispatching?
var fmv_dispatching: bool = false

# Are we in Brazil? (only Uneven is)
var portuguese: bool = false

# Did the game end? You certainly just lost it.
var ended: bool = false

#After that, game's done, grab a soda

func idx_pick() -> String:
	if !rand_chosen:
		rand_idx = str(randi()%6+1)
		rand_chosen = true
	return rand_idx

func typewritter(delta: float) -> void:
	if diag.percent_visible < 1.0 and !fmv_dispatching:
		diag.percent_visible += delta / 3.0

func dict_change(f: String) -> void:
	var idx_type = "Init"
	var idx_name = "name"
	var idx_text = "text"
	var final_f = f
	if final_f != "":
		var file = File.new()
		if diag_switch:
			final_f = "capsule"
		file.open("res://assets/dialogue/" + final_f + ".json", file.READ)
		dict = parse_json(file.get_as_text())
		file.close()
		if visited[scene_pos]:
			idx_type = idx_pick()
		if portuguese:
			idx_name = "pt_name"
			idx_text = "pt_text"
		speaker.text = dict[idx_type][idx_name]
		diag.text = dict[idx_type][idx_text]
	else:
		speaker.text = ""
		diag.text = ""

func flag_click() -> void:
	if portuguese:
		portuguese = false
	else:
		portuguese = true
	flagster.frame ^= 1
	dict_change(dict_files[scene_pos])

# Dispatch FMV video, based on L/R movement scheme, vars.
func stream_set(pos: int) -> void:
	if !television_on and freezer_open:
		video.set_stream(load("res://assets/fmv/end.webm"))
		video.play()
		audio.stream_paused = true
		fmv_dispatching = true
		diag.percent_visible = 0.0
		flagster.visible = false
		ended = true
		return
	
	var final_pos = scr_fmv[scenes[scene_pos][pos]]
	
	if scene_pos == 0 and !television_on:
		if pos == 0:
			final_pos = scr_fmv[30]
		else:
			final_pos = scr_fmv[31]
	
	if scene_pos == 5 and !television_on:
		if pos == 2:
			final_pos = scr_fmv[32]
	
	if scene_pos == 1 and !television_on:
		if pos == 0:
			final_pos = scr_fmv[33]
	
	if scene_pos == 2 and freezer_open:
		if pos == 2:
			final_pos = scr_fmv[29]
	
	if scene_pos == 3 and freezer_open:
		if pos == 0:
			final_pos = scr_fmv[26]
		else:
			final_pos = scr_fmv[27]
	
	if scene_pos == 4 and freezer_open:
		if pos == 0:
			final_pos = scr_fmv[23]
	
	if !visited[scene_pos]:
		visited[scene_pos] = true
	
	video.set_stream(load("res://assets/fmv/" + final_pos + ".webm"))
	video.play()
	rand_chosen = false
	fmv_dispatching = true
	diag.percent_visible = 0.0

# Dispatch new static screen texture.
func tex_set() -> void:
	var final_pos = scr_static[scenes[scene_pos][1]] 
	
	if scene_pos == 0 and !television_on:
		final_pos = scr_static[8]
	
	if scene_pos == 3 and freezer_open:
		final_pos = scr_static[4]
	if scene_pos == 4 and !freezer_open:
		final_pos = scr_static[6]
	
	texture = load("res://assets/static/" + final_pos + ".png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = OS.window_size / Vector2(320, 240)
	flagster.get_node("Area2D").connect("clicked", self, "flag_click")
	video.set_stream(load("res://assets/fmv/start.webm"))
	video.play()
	rand_chosen = false
	fmv_dispatching = true
	diag.percent_visible = 0.0
	tex_set()
	yield(get_tree().create_timer(3.0), "timeout")
	audio.play()

# For music change after ending
var music_oneshot: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fmv_dispatching = video.is_playing()
	
	if ended:
		if !fmv_dispatching:
			audio.stream_paused = false
			if !music_oneshot:
				audio.stream = load("res://assets/audio/calm-blue-lake.ogg")
				audio.play()
				music_oneshot = true
		texture = load("res://assets/static/termina.png")
		speaker.text = "The Weird Room Lightstorm,\nby Uneven Prankster."
	
	if Input.is_action_just_pressed("continue") and !ended:
		if scene_pos == 0:
			if television_on:
				video.set_stream(load("res://assets/fmv/television_shutoff.webm"))
				television_on = false
			else:
				video.set_stream(load("res://assets/fmv/television_turnon.webm"))
				television_on = true
			video.play()
			fmv_dispatching = true
		
		if scene_pos == 3:
			if freezer_open:
				video.set_stream(load("res://assets/fmv/freezer_close.webm"))
				freezer_open = false
			else:
				video.set_stream(load("res://assets/fmv/freezer_open.webm"))
				freezer_open = true
			video.play()
			fmv_dispatching = true
	
	# Quit the game!
	if Input.is_action_just_pressed("end_game"):
		get_tree().quit()
	
	# Movement scheme, will trigger a video dispatch.
	if Input.is_action_just_pressed("mov_left") and !fmv_dispatching and !ended:
		stream_set(0)
		scene_pos -= 1
	if Input.is_action_just_pressed("mov_right") and !fmv_dispatching and !ended:
		stream_set(2)
		scene_pos += 1
	
	if Input.is_action_just_pressed("switchy") and !ended:
		if !diag_switch:
			diag_switch = true
		else:
			diag_switch = false
	
	# Clamp scene_pos to -1 < scene_pos > (scenes.size - 1)
	# Not doing otherwise will make OOB/confusing access.
	if(scene_pos > (scenes.size() - 1)):
		scene_pos = 0
	if(scene_pos < 0):
		scene_pos = (scenes.size() - 1)
	
	if !fmv_dispatching:
		video.visible = false
		speaker.visible = true
		diag.visible = true
		if !ended:
			boxer.visible = true
			if scene_pos == 5:
				swinfo.visible = true
	else:
		video.visible = true
		diag.visible = false
		speaker.visible = false
		boxer.visible = false
		swinfo.visible = false
	
	if !ended:
		dict_change(dict_files[scene_pos])
		typewritter(delta)
		tex_set()
