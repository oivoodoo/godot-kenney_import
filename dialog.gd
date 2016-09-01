tool
extends ConfirmationDialog

var src_fs
var import_plugin
var logger

func configure(_import_plugin, path, metadata):
	import_plugin = _import_plugin

	if (metadata):
		# metadata from previous import exists, fill in fields
		assert( metadata.get_source_count() > 0 )
		# Always expand the source paths
		var src_path = import_plugin.expand_source_path( metadata.get_source_path(0) )
		get_node("src_file").set_text(src_path)


func _ready():
	src_fs = FileDialog.new()
	src_fs.set_mode(FileDialog.MODE_OPEN_FILE)
	src_fs.set_access(FileDialog.ACCESS_FILESYSTEM) #access all filesystem, not only res://
	src_fs.add_filter("*.xml")
	src_fs.connect("file_selected", self, "_on_src_selected")

	add_child(src_fs)

	set_hide_on_ok(true)
	get_ok().set_text("Import!")


func _on_src_browse_pressed():
	src_fs.popup_centered_ratio()


func _on_src_selected(path):
	get_node("src_file").set_text(path)


func _on_KenneyImport_confirmed():
	# Create an import metadata
	var metadata = ResourceImportMetadata.new()
	# Add the source files, always validate the source path

	var path = get_node("src_file").get_text()
	metadata.add_source(import_plugin.validate_source_path(path))

	import_plugin.import(metadata)

	# Perform regular import
	# if (err!=OK):
	#	get_node("error").set_text("Error Importing!")
	#	get_node("error").popup_centered_minsize()
