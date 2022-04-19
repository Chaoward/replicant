extends TextureRect

const BG_PATH = "res://Cutscene/background/"
const FILE_TYPES = [".png", ".PNG", ".jpg", ".jpeg", ".gif"]
var tween: Tween

signal complete(msg)


func set(name: String, coloring: String = "none"):
	var fileType: String = ""
	# check if file exist
	var dir = Directory.new()
	for type in FILE_TYPES:
		if dir.file_exists(BG_PATH + name + type):
			fileType = type
			break
	if fileType.empty():
		return print("ERROR: BG file not found")
	
	self.set_texture( load(BG_PATH + name + fileType) )
	
	match coloring:
		"night":
			self.modulate = Color(0, 0.4, 0.5, self.modulate.a)
		_:
			self.modulate = Color(1, 1, 1, self.modulate.a)
			
			
			
func set_withfade(name: String, coloring: String = "none"):
	# fade
	tween.interpolate_property(self,
		"modulate:a",
		null,
		0,
		0.3, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()
	yield(tween, "tween_all_completed")
	# change bg
	set(name, coloring)
	# unfade
	tween.interpolate_property(self,
		"modulate:a",
		null,
		1,
		0.3, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.0
	)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("complete")



func _ready():
	tween = Tween.new()
	self.add_child(tween)
