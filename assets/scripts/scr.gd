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
var dialogue : TWRLDialogue = TWRLDialogue.new()
var rand_idx : int = 0
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

func idx_pick() -> int:
	if !rand_chosen:
		rand_idx = randi()%dialogue.en_diag.size()
		rand_chosen = true
	return rand_idx

func idx_clamp(newidx : int) -> void:
	var fdex : int = scene_pos + newidx
	if(fdex > (scenes.size() - 1)):
		fdex = 0
	if(fdex < 0):
		fdex = (scenes.size() - 1)
	scene_pos = fdex

func typewritter(delta: float) -> void:
	if diag.percent_visible < 1.0 and !fmv_dispatching:
		diag.percent_visible += delta / 3.0

func dict_change(f: String) -> void:
	var final_f = f
	if final_f != "":
		if diag_switch:
			final_f = "capsule"
		dialogue = load("res://assets/dialogue/" + final_f + ".tres")
		
		if portuguese:
			speaker.text = dialogue.pt_name
			if !visited[scene_pos]:
				diag.text = dialogue.pt_init
			else:
				diag.text = dialogue.pt_diag[idx_pick()]
		else:
			speaker.text = dialogue.en_name
			if !visited[scene_pos]:
				diag.text = dialogue.en_init
			else:
				diag.text = dialogue.en_diag[idx_pick()]
	else:
		speaker.text = ""
		diag.text = ""

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
	
	if !television_on:
		if scene_pos == 0:
			if pos == 0:
				final_pos = scr_fmv[30]
			else:
				final_pos = scr_fmv[31]
		
		if scene_pos == 5:
			if pos == 2:
				final_pos = scr_fmv[32]
		
		if scene_pos == 1:
			if pos == 0:
				final_pos = scr_fmv[33]
	
	if freezer_open:
		if scene_pos == 2:
			if pos == 2:
				final_pos = scr_fmv[29]
		
		if scene_pos == 3:
			if pos == 0:
				final_pos = scr_fmv[26]
			else:
				final_pos = scr_fmv[27]
		
		if scene_pos == 4:
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
	
	if freezer_open:
		if scene_pos == 3:
			final_pos = scr_static[4]
	else:
		if scene_pos == 4:
			final_pos = scr_static[6]
	
	texture = load("res://assets/static/" + final_pos + ".png")

func _ready() -> void:
	randomize()
	
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

func _process(delta: float) -> void:
	# Quit the game!
	if Input.is_action_just_pressed("end_game"):
		get_tree().quit()
	
	fmv_dispatching = video.is_playing()
	
	if ended:
		if !fmv_dispatching:
			audio.stream_paused = false
			if !music_oneshot:
				audio.stream = load("res://assets/audio/calm-blue-lake.ogg")
				audio.play()
				music_oneshot = true
		texture = load("res://assets/static/termina.png")
		if portuguese:
			speaker.text = "The Weird Room: Lightstorm,\nfeito por Uneven Prankster."
		else:
			speaker.text = "The Weird Room: Lightstorm,\nby Uneven Prankster."
	
	if Input.is_action_just_pressed("continue") and !ended:
		if scene_pos == 0:
			if television_on:
				video.set_stream(load("res://assets/fmv/television_shutoff.webm"))
			else:
				video.set_stream(load("res://assets/fmv/television_turnon.webm"))
			television_on = !television_on
		
		if scene_pos == 3:
			if freezer_open:
				video.set_stream(load("res://assets/fmv/freezer_close.webm"))
			else:
				video.set_stream(load("res://assets/fmv/freezer_open.webm"))
			freezer_open = !freezer_open
		
		if scene_pos == 0 or scene_pos == 3:
			video.play()
			fmv_dispatching = true
			tex_set()
	
	# Movement scheme, will trigger a video dispatch.
	if !ended:
		if !fmv_dispatching:
			if Input.is_action_just_pressed("mov_left"):
				stream_set(0)
				idx_clamp(-1)
				tex_set()
				dict_change(dict_files[scene_pos])
			elif Input.is_action_just_pressed("mov_right"):
				stream_set(2)
				idx_clamp(1)
				tex_set()
				dict_change(dict_files[scene_pos])
			
		if Input.is_action_just_pressed("switchy"):
			diag_switch = !diag_switch
			dict_change(dict_files[scene_pos])
	
	if !fmv_dispatching:
		flagster.visible = true
		video.visible = false
		speaker.visible = true
		diag.visible = true
		if !ended:
			if dict_files[scene_pos] != "":
				boxer.visible = true
			if scene_pos == 5:
				swinfo.visible = true
	else:
		flagster.visible = false
		video.visible = true
		diag.visible = false
		speaker.visible = false
		boxer.visible = false
		swinfo.visible = false
	
	if !ended:
		typewritter(delta)


func _on_Area2D_clicked() -> void:
	portuguese = !portuguese
	if portuguese:
		swinfo.text = "Mude entre Cone/Capsula\nao apertar S."
	else:
		swinfo.text = "Switch between Cone/Capsule\nby pressing S."
	flagster.frame ^= 1
	dict_change(dict_files[scene_pos])
