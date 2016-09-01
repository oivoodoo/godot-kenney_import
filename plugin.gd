tool
extends EditorPlugin

var importer

func _enter_tree():
	importer = preload("res://addons/kenney_importer/importer.gd").new()
	importer.config(get_base_control())
	add_import_plugin(importer)

func _exit_tree():
	remove_import_plugin(importer)