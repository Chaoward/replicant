extends Control

const CACHE_LIMIT = 8
var SCREEN_CENTER: Vector2
var spacing = 400	# 200 px
var tween: Tween
var cache: Array = []	# Holds dictionaries (see below for details)
"""
		{
			"name": SpriteName,
			"radioMask": bool,		# this could change into a tag list for different types of masks
			"y_offset": float		# in case you want to make characters shorter
		}
"""


func add(name: String, y_offset: float = 0, radioMask: bool = false):
	# checks if exist
	for p in cache:
		if p.name == name:
			return print("Dup found! Skipped adding portrait")
	# check cache size
	if size() + 1 >= 8:
		self.remove_child( get_child(size()-1) )
		cache.pop_back()

	var newPort = {
		"name": name,
		"radioMask": radioMask,
		"y_offset": y_offset
	}
	var newNode = Sprite.new()
	newNode.modulate.a = 0	# sets opacity to 0
	newNode.set_texture( load("res://Cutscene/portraits/" + name + ".png") )
	newNode.set_name(name)
	newNode.position = Vector2( SCREEN_CENTER.x - 60, SCREEN_CENTER.y + y_offset )
	cache.push_back(newPort)
	self.add_child( newNode )		# unsure if child will reference node in array 
	# update positions
	update_positions()
	tween.interpolate_property(newNode,
		'modulate',
		null,
		Color(1,1,1,1),
		.3
	);
	tween.interpolate_property(newNode,
		'position:x',
		null,
		newNode.position.x + 60,
		.5, Tween.TRANS_QUAD, Tween.EASE_OUT
	);
	tween.start();
	
	
	
func update_positions():
	#var newPos: Array = []	# [Vector2]
	# calculations for each position loaded into array
	for i in range(size() - 1):
		var x_pos = (i * spacing) - ( size()/2 * spacing ) + SCREEN_CENTER.x	# equation to seperate portraits based on position in array
		#var x_pos = spacing * ( (size()/2) + ( i if size() % 2 != 0 else 0 ) - i) * (-1 if i > size()/2 else 1)
		tween.interpolate_property(
			self.get_child(i),
			'position',
			self.get_child(i).get_position_in_parent(),
			Vector2( x_pos, SCREEN_CENTER.y + cache[i].y_offset),
			.5, Tween.TRANS_QUAD, Tween.EASE_OUT
		);
	# move to positions
	tween.start();
	
	
	
func focus_speaker(speaker: String):
	for p in cache:
		if p.name == speaker:
			pass
	
	
func dim(p: Sprite, color: Color = Color(Color(.5,.5,.5,1))):
	tween.interpolate_property(p,
		'modulate',
		null,
		color,
		.3
	);
	tween.start();
	
func undim(p: Sprite):
	dim(p, Color(1,1,1,1))
	
	
func size():
	return cache.size()


func _ready():
	SCREEN_CENTER = Vector2(self.rect_pivot_offset.x, self.rect_pivot_offset.y)
	tween = Tween.new()
	add_child(tween)
