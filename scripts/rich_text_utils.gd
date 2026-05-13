class_name RichTextUtils
extends RefCounted

const TAG_PATTERN := "\\[(\\/)?([a-zA-Z]+)(?:=([^\\]]+))?\\]"
const HEX_COLOR_PATTERN := "^#?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$"


static func sanitize(value: String) -> String:
	var tag_regex := RegEx.new()
	if tag_regex.compile(TAG_PATTERN) != OK:
		return _escape_literal(value)
	var result := ""
	var cursor := 0
	for match in tag_regex.search_all(value):
		var start := match.get_start()
		result += _escape_literal(value.substr(cursor, start - cursor))
		var original_tag := match.get_string(0)
		var is_closing := match.get_string(1) == "/"
		var tag_name := match.get_string(2).to_lower()
		var attribute := match.get_string(3).strip_edges()
		result += _sanitize_tag(tag_name, is_closing, attribute, original_tag)
		cursor = match.get_end()
	result += _escape_literal(value.substr(cursor, value.length() - cursor))
	return result


static func centered(value: String) -> String:
	return "[center]%s[/center]" % sanitize(value)


static func _sanitize_tag(tag_name: String, is_closing: bool, attribute: String, original_tag: String) -> String:
	match tag_name:
		"b", "i", "u":
			if attribute.is_empty():
				return "[/%s]" % tag_name if is_closing else "[%s]" % tag_name
		"color":
			if is_closing and attribute.is_empty():
				return "[/color]"
			if not is_closing and _is_valid_color_attribute(attribute):
				return "[color=%s]" % attribute
		"br":
			if not is_closing and attribute.is_empty():
				return "[br]"
	return _escape_literal(original_tag)


static func _is_valid_color_attribute(attribute: String) -> bool:
	if attribute.is_empty():
		return false
	var color_regex := RegEx.new()
	if color_regex.compile(HEX_COLOR_PATTERN) != OK:
		return false
	return color_regex.search(attribute) != null


static func _escape_literal(value: String) -> String:
	var escaped := value.replace("[", "__LB__").replace("]", "__RB__")
	return escaped.replace("__LB__", "[lb]").replace("__RB__", "[rb]")