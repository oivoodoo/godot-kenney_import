tool
extends EditorImportPlugin


const SEL_INPUT_META = 0;
const SEL_OUTPUT_TEX = 1;

var dialog = null

func get_name():
	return "kenny_importer"

func get_visible_name():
	return "Kenny Importer"

func import_dialog(path):
	var md = null
	if (path != ""):
		md = ResourceLoader.load_import_metadata(path)

	dialog.configure(self, path, md)
	dialog.popup_centered()

func config(base_control):
	dialog = preload("res://addons/kenney_importer/dialog.tscn").instance()
	base_control.add_child(dialog)

func import(metadata):
	var path = metadata.get_source_path(0)
	load_spritesheet(path)

class SpriteFrame extends Reference:
	var name = ""
	var region = Rect2(0, 0, 0, 0)
	var rotation = 0

func load_spritesheet(path):
	var logger = File.new()
	logger.open("/tmp/mario.log", File.WRITE)

	var file = File.new()
	file.open(path, File.READ)
	if file.is_open():
		var content = file.get_as_text()
		var atlas = _parse(content)
		_save(path, atlas)
		logger.store_line(content)
	file.close()

	logger.close()

func _get_parent_dir(path):
	var fileName = path.substr(0, path.find_last("/"))
	return fileName

func _get_file_name(path):
	var filename = path.substr(path.find_last("/")+1, path.length() - path.find_last("/")-1)
	var pos = filename.find_last(".")
	if pos != -1:
		filename = filename.substr(0, pos)
	return filename

func _save(path, atlas):
	var tex = null
	if ResourceLoader.has(path):
		tex = ResourceLoader.load(path)
	else:
		tex = ImageTexture.new()
	tex.load(path)

	if not ResourceLoader.has(path):
		tex.set_path(path)
	else:
		tex.take_over_path(path)
	tex.set_name(path)
	ResourceSaver.save(path, tex)

	var target_dir = _get_parent_dir(path)

	for s in atlas.sprites:
		var atex = AtlasTexture.new()
		var ap = str(target_dir, "/", _get_file_name(path), ".", _get_file_name(s.name), ".atex")
		print(ap)
		if not ResourceLoader.has(ap):
			atex.set_path(ap)
		else:
			atex.take_over_path(ap)
		atex.set_path(ap)
		atex.set_name(_get_file_name(s.name))
		atex.set_atlas(tex)
		atex.set_region(s.region)
		ResourceSaver.save(ap, atex)
	return tex

func _parse(content):
	var atlas = {}
	atlas["sprites"] = []
	var parser = XMLParser.new()

	if OK == parser.open_buffer(content.to_utf8()):
		var err = parser.read()

		while(err != ERR_FILE_EOF):
			if parser.get_node_type() == parser.NODE_ELEMENT:
				if parser.get_node_name() == "TextureAtlas":
					atlas["imagePath"] = parser.get_named_attribute_value("imagePath")
					if parser.has_attribute("width"):
						atlas["width"] = parser.get_named_attribute_value("width")
					if parser.has_attribute("height"):
						atlas["height"] = parser.get_named_attribute_value("height")
				elif parser.get_node_name() == "SubTexture":
					var sprite = SpriteFrame.new()
					sprite.name = parser.get_named_attribute_value("name")
					sprite.region = Rect2(parser.get_named_attribute_value("x"), parser.get_named_attribute_value("y"), parser.get_named_attribute_value("width"), parser.get_named_attribute_value("height"))
					sprite.rotation = 0
					atlas["sprites"].append(sprite)
			err = parser.read()
		return atlas
