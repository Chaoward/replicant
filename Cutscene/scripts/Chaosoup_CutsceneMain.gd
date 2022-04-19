extends CanvasLayer

const LANGUAGES_PATH = "res://Cutscene/language/"
const CUTSCENES_PATH = "res://Cutscene/Embedded/"

var file = File.new()
var translatedFile = null
export var fileName: String = "sampleCut.txt"
export var language: String = "en"

var waitForAnim: float = 0.0

onready var textBox = $CenterContainer
onready var portraits = $Portraits
onready var background = $Background
onready var textHistory = $CutsceneHistory

var isWaiting = false



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
		isWaiting = false
		var line: String = file.get_line()
		if file.eof_reached() and line.empty():
			return end_cutscene()
		elif line.empty():
			print("empty line")
			continue
		
		print(line)
		
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
				# undim speaker
				portraits.focus_speaker(tmp_speaker)
			else:
				tmp_text = line
				portraits.undimAll()
			# display text to chatBox
			textBox.openTextbox()
			textHistory.set_history([[tmp_speaker, tmp_text]])		# push to history
			textBox.setContents(tmp_text, tmp_speaker)
			"""
			textBox.text.visible_characters=0
			textBox.text.bbcode_text = tmp_text
			textBox.speakerActor.text = tmp_speaker
			"""
			"""
			tw.interpolate_property(text,"visible_characters",0,text.text.length(),
				1/TEXT_SPEED*text.text.length(),
				Tween.TRANS_LINEAR,
				Tween.EASE_IN,
				waitForAnim
			)
			tw.start()
			"""
			isWaiting = true
			return
		#-----------------------------------------------------------------------------------------------
		
		#----- opcode commands----------------------------
		var args = line.substr(1).split(" ", false) 	# removes "#" returns [cmdLine, other args]
		match args[0]:
			"bg": 
				if args.size() < 2:
					print("BG ERROR: requires file name of the background after the command")
				textBox.clear()
				textBox.closeTextbox()
				
				if args.size() > 2:
					background.set_withfade(args[1], args[2])
				else:
					background.set_withfade(args[1])
				yield(background, "complete")		# wait for signal from set_withfade(), because for some reason it does not yield in the function

			"portrait":
				if args.size() < 2:
					print("\"portrait\" requires a name to the PNG file")
					continue
				var temp = args[1].split(",") if args[1].find(",") else args[1]
				if temp.size() > 1:
					portraits.add(temp[0], float(temp[1]))
				else:
					portraits.add(temp[0])
	
			"cache_portraits":	#WIP
				if args.size() < 2:
					print("\"load_to_cache\" requires a name to the PNG file")
					continue
				args = args[1].split(" ")	# array of entries
				for entry in args:
					var temp = entry.split(",")		# [ name: String, y_offset: float, radioMask: bool ]
					match temp.size():				# adding multiple could be implemented better
						1:
							portraits.addToCache(temp[0])
						2:
							portraits.addToCache(temp[0], float(temp[1]))
						_:
							portraits.addToCache(temp[0], float(temp[1]), temp[2] == "true" )

			"hide_portraits":
				portraits.hideAll()
				
			"clear_portraits":	#WIP
				portraits.clear()
				
			"pause":
				return
			_:
				print("unkown command: " + args[0])


func end_cutscene(nextCutscene: String = ""):
	isWaiting = false
	print("Hit the end. Now I will kill myself!")
	textBox.closeTextbox()
	# * fade *
	# * clear portraits and end other assets *
	if !nextCutscene.empty():
		if load_cutscene(nextCutscene):
			advance_text()
	else:
		pass
		# * Back to main menu *



"""
func closeTextbox(t:Tween,delay:float=0):
	if !$CenterContainer.visible:
		return
	#t.append(textboxSpr,'scale:y',0,.3).set_trans(Tween.TRANS_QUAD)
	#print("Closing textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"modulate:a",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.start()
	yield(t, "tween_all_completed")
	$CenterContainer.visible = false
	emit_signal("ready")

func openTextbox(t:Tween,delay:float=0):
	if $CenterContainer.visible:
		return
	$CenterContainer.visible = true
	#print("Opening textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"modulate:a",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.start()
	yield(t, "tween_all_completed")
	emit_signal("ready")
"""	


func _ready():
	textBox.closeTextbox()
	
	if load_cutscene(CUTSCENES_PATH + fileName, language):
		advance_text()
		isWaiting = true
	else:
		pass
		# * error/back to main menu *
		
		
func _process(delta):
	if Input.is_action_just_released("ui_select") and isWaiting:
		advance_text()
		#isWaiting = true 	# for some reasson this line is never executed after running "bg" command
