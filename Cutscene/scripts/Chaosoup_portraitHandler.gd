extends Node2D

# NOTE FOR USE: position the node in center of screen. Y position is up to preference.

const PORTRAITS_PATH = "res://Cutscene/portraits/"
const DISPLAY_LIMIT: int = 6
var SCREEN_CENTER: Vector2	# current position of this node
var spacing: float = 400	# 400 px
var tween: Tween
var cache: Array = []	# Holds dictionaries (see below for details)
"""
		{
			"node": SpriteNode		# pointer to the child
			"name": String,	
			"radioMask": bool,		# this could change into a tag list for different types of masks
		}
"""

# adds new element to cache at the end
func _push(name: String, y_offset: float = 0, radioMask: bool = false):
	#checks if image file exist
	var dir = Directory.new()
	if !dir.file_exists(PORTRAITS_PATH + name + ".png"):
		print("ERROR Portrait Image Not Found!")
		return null
	# checks if dup exist
	for p in cache:
		if p.name == name:
			print("Dup found! Skipped adding portrait")
			return null

	var newPort = {
		"node": null,
		"name": name,
		"radioMask": radioMask,
	}
	var newNode = Sprite.new()
	newNode.modulate.a = 0	# sets opacity to 0
	newNode.set_texture( load("res://Cutscene/portraits/" + name + ".png") )
	newNode.set_name(name)
	newNode.centered = true
	newNode.position = Vector2( -60, y_offset )
	self.add_child( newNode )				# add as a child of this node
	newPort["node"] = self.get_node(name)	# set to pointer of newly added node
	cache.push_back(newPort)
	return cache.back() 					# returns last element, which would be the recently pushed



func add(name: String, y_offset: float = 0, radioMask: bool = false):
	var newPort = _push(name, y_offset, radioMask)
	if newPort == null:
		return print("ERROR: Fail to add portrait")
	# update positions
	update_positions()
	tween.interpolate_property(newPort["node"],
		'modulate',
		null,
		Color(1,1,1,1),
		.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.1
	);
	tween.start()
	

# similar to add() but portraits will be hidden until use
func addToCache(name: String, y_offset: float = 0, radioMask: bool = false):
	var newPort = _push(name, y_offset, radioMask)
	if newPort == null:
		return print("ERROR: Fail to add portrait")
	hidePortrait(newPort["name"])
	

"""
	Tweens portraits to updated positions if changed.
	Positions are depended on moving the Portraits node to the left as
	it's used as a initial position.
"""
func update_positions():
	#var ini_x_pos = ( -(size()-1) * spacing)/2
	#self.rect_position.x = SCREEN_CENTER.x - ( ( (size()-1) * spacing)/2 )
	#var ini_x_pos = SCREEN_CENTER.x - (( (size()-1) * spacing)/2 )	#position of Portraits node will act as the initial position
	#ini_x_pos = 0 if ini_x_pos < 0 else ini_x_pos
	var ini_x_pos = 0
	var i = 0
	for p in cache:					# FOR some reason for-looping the elements works better for tweening, compared to "i in range(size()-1)"
		if i >= DISPLAY_LIMIT or p["node"].visible == false:
			continue
		
		tween.interpolate_property(p["node"],
			'position:x',
			null,
			spacing * i,
			0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.1		#NOTE TO SELF: add a delay for interpolating multiple of the same property
		)
		i += 1
	ini_x_pos = SCREEN_CENTER.x - (( (i-1) * spacing)/2 )
	tween.interpolate_property(self,
		"position:x",
		null,
		ini_x_pos,
		0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.1
	)
	tween.start()
	
	"""
	print("Node Pos X: " + String(self.position.x))
	for p in cache:
		print( p["name"] + " : " + String(p["node"].position.x) + ", " + String(p["node"].position.y) )
	"""
	

# ----- focus_speaker -------------------------
# dims all portraits in cutscene, but undims the passed in speaker
# No change if speaker not found
func focus_speaker(speaker: String):
	if !self.has_node(speaker):
		return
	for p in cache:
		if p["name"] == speaker:
			activate(speaker)
			p["node"].z_index = DISPLAY_LIMIT		# puts sprite on top Z
			undim(p["node"])
			update_positions()
		else:
			p["node"].z_index = 0
			dim(p["node"])
	


#===== Visibility Methods ======================================================
"""
	These functions just activate and deactivate portraits with tweens
	to fade in and out. They will still be in the cache so that when
	focus_speaker() is called they will be added back into the cutscene.
	
	Allows for clearing the scene of portraits but retain portrait data
	to add back during something like a cutscene transition without having
	to use "#portrait" again.
"""
#----- Hide functions ----------------------------
func hidePortrait(name: String):
	if !self.has_node(name):
		return
	var node = self.get_node(name)
	if !node.visible:
		return
		
	tween.interpolate_property(node,
		"modulate",
		null,
		Color(1,1,1,0),
		0.2
	)
	tween.start()
	yield(tween, "tween_all_completed")
	node.visible = false
	
func hideAll():
	for p in cache:
		hidePortrait(p["name"])

		
#----- Unhide -------------------------
func activate(name: String):
	if !self.has_node(name):
		return
	var node = self.get_node(name)
	if node.visible:
		return
	node.visible = true
	tween.interpolate_property(node,
		"modulate",
		null,
		Color(1,1,1,1),
		0.3
	)
	update_positions()
	
func activateAll():
	var i = 0
	for p in cache:
		if i >= DISPLAY_LIMIT:
			return
		activate(p["name"])
		i += 1
#===== *END* Visibility *END* ==================================================


#===== Dimming Methods =========================================================
func dim(p: Sprite, color: Color = Color(Color(.5,.5,.5,1))):
	if p.modulate == color:
		return
	tween.interpolate_property(p,
		'modulate',
		null,
		color,
		.3
	);
	tween.start();
	
func undim(p: Sprite):
	dim(p, Color(1,1,1,1))
	
func undimAll():
	for p in cache:
		undim(p["node"])
#===== *END* Dimming Methods *END* =============================================
	

func size():
	return cache.size()
	
func clear():
	for p in cache:
		self.remove_child(p["node"])
	cache.clear()

func _ready():
	SCREEN_CENTER = self.position
	tween = Tween.new()
	add_child(tween)
