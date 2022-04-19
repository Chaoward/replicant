extends Node2D

onready var TEXT_SPEED: float = max(50,1)

onready var contents = $textActor_better
onready var textboxSpr = $textBackground
onready var speakerActor = $SpeakerActor
onready var tw = $TextboxTween

signal complete(msg)

func setContents(newtext: String, speaker: String = "", delay: float = 0.2):
	contents.visible_characters=0
	contents.bbcode_text = newtext
	speakerActor.text = speaker
	tw.interpolate_property(contents,"visible_characters",0,contents.text.length(),
		1/TEXT_SPEED*contents.text.length(),
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		delay
	)
	tw.start()

#Because tween is werid ,and yield() won't yield
func _tweenBox(values: Array):
	tw.interpolate_property(textboxSpr,"rect_scale:y",values[0],values[1],.3,Tween.TRANS_QUAD,Tween.EASE_IN,values[2])
	tw.interpolate_property(speakerActor,"rect_scale:y",values[0],values[1],.3,Tween.TRANS_QUAD,Tween.EASE_IN,values[2])
	tw.interpolate_property(speakerActor,"modulate:a",values[0],values[1],.3,Tween.TRANS_QUAD,Tween.EASE_IN,values[2])
	tw.start()
	yield(tw, "tween_all_completed")
	emit_signal("complete")


func closeTextbox(delay:float=0):
	if !self.visible:
		return emit_signal("complete")
	#_tweenBox([1, 0], delay)
	"""
	tw.interpolate_property(textboxSpr,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	tw.interpolate_property(speakerActor,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	tw.interpolate_property(speakerActor,"modulate:a",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	tw.start()
	"""
	#yield(tw, "tween_all_completed")
	call_deferred("_tweenBox", [1, 0, delay])
	yield(self, "complete")
	self.visible = false
	

func openTextbox(delay:float=0):
	if self.visible:
		return emit_signal("complete")
	self.visible = true
	"""
	tw.interpolate_property(textboxSpr,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	tw.interpolate_property(speakerActor,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	tw.interpolate_property(speakerActor,"modulate:a",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	tw.start()
	"""
	#_tweenBox([0, 1], delay)
	call_deferred("_tweenBox", [0, 1, delay])	# Having it executed through the process tick (internet's words not mine)
	yield(self, "complete")						# extra yield here because yield() in _tweenBox() won't wait
	

func clear():
	contents.text = ""
	speakerActor.text = ""



func _ready():
	pass # Replace with function body.
