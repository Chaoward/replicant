extends Node2D

#arrays can't be const since they're passed by reference
var SCREEN_CENTER_X
const IMAGE_CENTER_X = 512 #Size of image/2
var portraitPositions:Array

var lastLoaded: String
var _offset: int
var numPortraits:int = 0
var idx: int = -1
var is_active:bool = false
var is_masked:bool=false

var portrait_textures:Array=[]
#var imageTex:Array=[]
var cur_expression:int=0
var mask1 = preload("res://Cutscene/maskBox.png")
var mask2 = preload("res://Cutscene/maskBox2.png")

var numberTex = preload("res://groove gauge 1x10.png")

var tween:Tween
var blendAdd:Light2D
#onready var tween = Tween.new()

func _draw():
	if portrait_textures.size()==0 or !is_instance_valid(portrait_textures[cur_expression]):
		#print("No texture present at idx "+String(cur_expression)+".")
		return
	if is_masked:
		draw_texture(mask1,Vector2(-196,14))
		draw_texture_rect_region(portrait_textures[cur_expression],
			Rect2(-319/2,26,319,457),
			Rect2(512-319/2,0,319,457)
		)
		#I'm pretty sure this isn't a normal overlay because it's not that blue in gfl.
		#There's also the whole distortion thing but I don't know how that's done (Is it a shader?).
		draw_texture(mask2,Vector2(-319/2,25),Color(1,1,1,.8))
	else:
		draw_texture(portrait_textures[cur_expression],Vector2(-IMAGE_CENTER_X,0))
		
	if OS.is_debug_build():
		draw_texture_rect_region(numberTex,
			Rect2(0,0,31,24),
			Rect2(0,24*idx,31,24)
		)
	

func _ready():
	#add_child(tween)
	#tween=$Tween
	tween = Tween.new()
	add_child(tween)
	
	#blendAdd = Light2D.new()
	#blendAdd.texture = load("res://Cutscene/VN MaskOverlay (stretch).png")
	
	#I don't know how to do it....
	#var b = load("res://Cutscene/BlendAddLoop.tscn")
	#blendAdd = b.instance()
	#add_child(blendAdd)
	update_portrait_positions(float(get_viewport().get_visible_rect().size.x/2))

	
func update_portrait_positions(center:float):
	SCREEN_CENTER_X = center
	#print(SCREEN_CENTER_X)
	portraitPositions = [
		[SCREEN_CENTER_X],
		[SCREEN_CENTER_X-250,SCREEN_CENTER_X+250], #separation of 200px
		[SCREEN_CENTER_X-400,SCREEN_CENTER_X,SCREEN_CENTER_X+400],
		[SCREEN_CENTER_X-450,SCREEN_CENTER_X-150,SCREEN_CENTER_X+150,SCREEN_CENTER_X+450]
	]
	
	if is_active:
		position.x=portraitPositions[numPortraits-1][idx]

func position_portrait(idx:int,isMasked:bool,_offset:int,numPortraits:int):
	print("curPortrait is "+lastLoaded)
	if _offset==null:
		_offset=0
	else:
		_offset=_offset*100
	
	self._offset = _offset;
	self.idx=idx; #Needed for dim/hl to function
	self.numPortraits=numPortraits
	
	
	print("idx: "+String(idx)+" numPortraits: "+String(numPortraits)+ " offset: "+String(_offset))
	if is_active:
		#Trace(portraitPositions[numPortraits][idx])
		#Trace(portraitPositions[numPortraits][idx]+self.offset)
		
		#self.actor:stoptweening():decelerate(.2):x(portraitPositions[numPortraits][idx]+self.offset)
		tween.remove_all()
		tween.interpolate_property(self,
			'position:x',
			null,
			portraitPositions[numPortraits-1][idx],
			.5, Tween.TRANS_QUAD, Tween.EASE_OUT
		);
		tween.start();
		return
	
	is_active = true #Because dimming will make invisible portraits visible...
	#assert(fileName)
	#self.actor:Load(THEME:GetPathB("StoryArea","overlay/"..fileName));
	#self.actor:stoptweening():diffusealpha(0);
	#self.set_modulate(Color(1,1,1,0))
	
	#self.actor:z(offset);
	
	
	
	assert(len(portraitPositions)>numPortraits-1, "portraitPositions doesn't go up to "+String(numPortraits))
	assert(portraitPositions[numPortraits-1][idx])
	
	is_masked=isMasked
	update() #Need to update if we're changing mask
	#Because this makes way too much sense right
	#Fuck godot the tweens suck complete ass
	#self.actor:x(portraitPositions[numPortraits][idx]+self.offset+100):decelerate(.2):x(portraitPositions[numPortraits][idx]+self.offset):diffusealpha(1)
	var endPosition = portraitPositions[numPortraits-1][idx]+_offset
	#var endPosition= SCREEN_CENTER_X
	print("End position "+String(endPosition))
	#offset.x = endPosition+100 if endPosition <= SCREEN_CENTER_X else endPosition-100
	#position.x = 0.0
	#modulate.a=1.0
	#print(offset)
	#print(modulate)
	tween.remove_all()
	if false: #Does not work properly yet. Tween probably is the wrong way to do it and it needs to be done with manual drawing
		position.x=endPosition
		tween.interpolate_property(self,
			'scale:y',
			0,
			1,
			.5, Tween.TRANS_QUAD, Tween.EASE_OUT
		);
	else:
		tween.interpolate_property(self,
			'position:x',
			#null,
			endPosition+100 if endPosition <= SCREEN_CENTER_X else endPosition-100,
			endPosition,
			.5, Tween.TRANS_QUAD, Tween.EASE_OUT
		);
	tween.interpolate_property(self,
		'modulate:a',
		0.0,
		1.0,
		.5, Tween.TRANS_QUAD, Tween.EASE_OUT
	);
	tween.start();

func stop():
	#return
	tween.remove_all()
	tween.interpolate_property(self,
		'position:x',
		null,
		self.get_position().x + 100 if self.get_position().x >= SCREEN_CENTER_X else self.get_position().x - 100,
		.5, Tween.TRANS_SINE, Tween.EASE_IN
	);
	tween.interpolate_property(self,
		'modulate:a',
		null,
		0.0,
		.5, Tween.TRANS_QUAD, Tween.EASE_IN
	);
	tween.start();
	is_active=false
	idx=-1
	
func dim():
	tween.interpolate_property(self,
		'modulate',
		null,
		Color(.5,.5,.5,1),
		.3
	);
	tween.start();

func undim():
	if !is_active:
		print("Portrait was asked to highlight, but it's not active?")
		print("idx: "+String(idx)+" offset: "+String(_offset))
		return
	tween.interpolate_property(self,
		'modulate',
		null,
		Color(1,1,1,1),
		.3
	);
	tween.start();

func is_tweening()->bool:
	return tween.is_active()

func set_texture_wrapper(sprName):
	lastLoaded=sprName
	if sprName in Globals.database:
		var toLoad = Globals.database[sprName]
		print("Got textures to load... "+String(toLoad))
		overdrive_set_texture(toLoad)
	else:
		print(sprName+" not in portrait database! Falling back...")
		overdrive_set_texture([sprName])

func overdrive_set_texture(toLoad:Array):
	portrait_textures = Array()
	portrait_textures.resize(toLoad.size())
	#imageTex=Array()
	#imageTex.resize(toLoad.size())
	for i in range(toLoad.size()):
		var sprName = toLoad[i]
		if sprName.ends_with(".png"):
			print("Hey moron, don't put .png in the portrait names!")
			sprName=sprName.rstrip(".png")
		#set_texture(load("res://Cutscene/Portraits/"+sprName+".png"))
		var f = File.new()
		if f.file_exists("res://Portraits/"+sprName+".png.import"):
			portrait_textures[i]=load("res://Portraits/"+sprName+".png")
		elif OS.has_feature("standalone"):
			var path = OS.get_executable_path().get_base_dir()+"/GameData/Portraits/"+sprName+".png"
			#print("Checking path "+path)
			if f.file_exists(path):
				print("Found external image file at "+path)
				var image = Image.new()
				f.open(path, File.READ)
				var buffer = f.get_buffer(f.get_len())
				match path.get_extension():
					"png":
						image.load_png_from_buffer(buffer)
					"jpg":
						image.load_jpg_from_buffer(buffer)

				f.close()
				image.lock()

				portrait_textures[i]=ImageTexture.new()
				portrait_textures[i].create_from_image(image);
				print(portrait_textures[i])
			else:
				printerr("Portrait "+sprName+"not embedded in pck and no external file!!")
		else:
			printerr("Portrait "+sprName+" not embedded in pck and no external file!!")
			
	print(portrait_textures)
	update()
