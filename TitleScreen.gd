extends Control

onready var database = Globals.chapterDatabase
#We do a little trolling
onready var mSelObjs = $ScrollContainer2/VBoxContainer
var biggestMissionNum:int=0

var font = preload("res://ChapterListingFont.tres")
var mSelObj = load("res://MSelObj.tscn")

func _ready():
	var c = $ScrollContainer/VBoxContainer
	for chapterName in database.keys():
		biggestMissionNum=max(database[chapterName].size(),biggestMissionNum)
		#var chapter:Globals.Chapter = database[chapterName]
		#biggestMissionNum=max(chapter.parts,biggestMissionNum)
		#print(chName)
		var n = Label.new()
		n.set("custom_fonts/font",font)
		n.set("mouse_filter",1)
		#n.margin_left=1000 #use VBOxContainer margin instead
		#TODO: Translate these
		n.text=String(chapterName)
		#n.set_meta("chapterName",chapterName) #lmao
		n.connect("gui_input",self,"handle_chapter_click",[chapterName])
		c.add_child(n)
	print(biggestMissionNum)
	for i in range(biggestMissionNum):
		var m = mSelObj.instance()
		mSelObjs.add_child(m)
	for m in mSelObjs.get_children():
		m.connect("button_pressed",self,"handle_btn_press")
		#m.connect("wtf",self,'test2')
	biggestMissionNum=mSelObjs.get_child_count() #We're never adding any more so it's fine
	#mSelObjs.queue_sort()

func handle_chapter_click(event:InputEvent,internalName:String):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("Clicked "+internalName)
		set_new_mission_listing(internalName)

func set_new_mission_listing(chapterName:String):
	var chapter:Array = database[chapterName]
	var chLength = chapter.size()
	#print(chapter)
	var t:Tween = $Tween
	for i in range(biggestMissionNum):
		var mSelObj = mSelObjs.get_child(i)
		if i < chLength:
			mSelObj.visible=true
			mSelObj.title.text=chapter[i].title
			mSelObj.desc.text=chapter[i].desc
			mSelObj.setNumParts(chapter[i].parts)
			#mSelObj.rect_position.x = i*500
			t.interpolate_property(mSelObj,"rect_position:x",i*500,0,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,i*.1)
			t.interpolate_property(mSelObj,"modulate:a",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,i*.1)
		else:
			mSelObj.visible=false
	t.start()

func handle_btn_press(vnPlayerDest:String):
	#print("lol")
	Globals.nextCutscene=vnPlayerDest+".txt"
	$FadeOut.visible=true
	$Tween.interpolate_property($FadeOut,"color:a",0,1,.5)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	get_tree().change_scene("res://Cutscene/CutsceneFromFile.tscn")
	#print("lol")
	
