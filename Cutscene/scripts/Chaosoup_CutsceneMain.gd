extends CanvasLayer

const LANGUAGES_PATH = "res://Cutscene/language/"
const PORTRAITS_PATH = "res://Cutscene/Portraits/"
const CUTSCENES_PATH = "res://Cutscene/Embedded/"

var file = File.new()
var translatedFile = null
export var fileName: String = "sampleCut.txt"
export var language: String = "en"

var waitForAnim: float = 0.0
onready var TEXT_SPEED: float = max(50,1)

onready var text = $CenterContainer/textActor_better
onready var textboxSpr = $CenterContainer/textBackground
onready var speakerActor = $CenterContainer/SpeakerActor
onready var textHistory = $CutsceneHistory
onready var tw = $TextboxTween

onready var portraits = $Portraits
var backgroundS: Array = []
var isPlaying = false



func load_cutscene(path: String, lang: String = "en"):
	file.close()
	# Translation File
	if lang != "en":
		if translatedFile != null:
			translatedFile.close()
		translatedFile = File.new()
		translatedFile.open(LANGUAGES_PATH + lang + "_" + fileName, File.READ)
		if !translatedFile.is_open():
			print("language file failed to open! Defaulting to EN")
			translatedFile = null
	else:
		translatedFile = null

	#Main File
	file.open(path, File.READ)
	if !file.is_open():
		print("Fail to open file!")
		return false

	return true


func advance_text():
	while true:
		var line: String = "" if file.eof_reached() else file.get_line()
		if line == "\n":
			print("empty line")
			continue
		elif line.empty():
			return end_cutscene()
		isPlaying = true
		
		#----- display dialogue -------------------------------------------------------------------------
		if !line.begins_with("#"):
			var tmp_text: String
			var tmp_speaker: String = ""
			# check for different languages
			if translatedFile != null:
				if !translatedFile.eof_reached():
					line = translatedFile.get_line()
			# text with a speaker
			if line.begins_with("/"):
				var args = line.substr(1).split(" ", false, 1)	# [speakerName, dialogue]
				tmp_text = args[1]
				tmp_speaker = args[0]
				# ** speaker code undim **
				# focus_speaker(tmp_speaker)
			else:
				tmp_text = line
			# ** display text to chatBox code here **
			text.visible_characters=0
			text.bbcode_text = tmp_text
			speakerActor.text = tmp_speaker
			#textHistory.push_back([tmp_speaker, text.text])
			openTextbox(tw, 0.5)
			tw.interpolate_property(text,"visible_characters",0,text.text.length(),
				1/TEXT_SPEED*text.text.length(),
				Tween.TRANS_LINEAR,
				Tween.EASE_IN,
				waitForAnim
			)
			tw.start()
			return
		#-----------------------------------------------------------------------------------------------
			
		#----- opcode commands----------------------------
		var args = line.substr(1).split(" ", false) 	# removes "#" returns a string array
		match args[0]:
			"portrait":
				if args.size() < 2:
					print("\"portrait\" requires a name to the PNG file")
					continue
				args = args[1].split(",") if args[1].find(",") else [args[1]]
				for newPort in args:
				# TODO: load sprite to a spawned in chid
					var temp = newPort.split(",")
					var dir = Directory.new()
					if dir.file_exists(PORTRAITS_PATH + temp[0] + ".png"):
						if temp.size() > 1:
							portraits.add(temp[0], temp[1])
						else:
							portraits.add(temp[0])
					else:
						print("ERROR Portrait Image Not Found!")
			_:
				print("unkown command: " + args[0])


func end_cutscene(nextCutscene: String = ""):
	isPlaying = false
	print("Hit the end. Now I will kill myself!")
	closeTextbox(tw, 0.5)
	# * fade *
	# * clear portraits and end other assets *
	if !nextCutscene.empty():
		if load_cutscene(nextCutscene):
			advance_text()
	else:
		pass
		# * Back to main menu *




func closeTextbox(t:Tween,delay:float=0):
	if !$CenterContainer.visible:
		return
	#t.append(textboxSpr,'scale:y',0,.3).set_trans(Tween.TRANS_QUAD)
	#print("Closing textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"modulate:a",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	$CenterContainer.visible = false

func openTextbox(t:Tween,delay:float=0):
	if $CenterContainer.visible:
		return
	$CenterContainer.visible = true
	#print("Opening textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"modulate:a",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)


func _ready():
	closeTextbox(tw)
	if load_cutscene(CUTSCENES_PATH + fileName, language):
		advance_text()
	else:
		pass
		# * error/back to main menu *
		
		
func _process(delta):
	if Input.is_action_just_released("ui_select") and isPlaying:
		advance_text()
