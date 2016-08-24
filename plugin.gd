tool

extends EditorPlugin

var plugin = null
var importer = preload("./gui.tscn")

func _enter_tree():
	print("ENTRT TREE")
	importer = importer.instance()
	get_base_control().add_child(importer)
	print("IMPORT PLUGIN")
