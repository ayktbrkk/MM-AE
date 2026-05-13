class_name UIFocusHelper
extends RefCounted

const AXIS_VERTICAL := 0
const AXIS_HORIZONTAL := 1


static func configure_linear(controls: Array[Control], axis := AXIS_VERTICAL) -> void:
	var items := _filter_focusable_controls(controls)
	if items.is_empty():
		return
	for index in range(items.size()):
		var control: Control = items[index]
		var previous_control: Control = items[index - 1] if index > 0 else items[items.size() - 1]
		var next_control: Control = items[index + 1] if index < items.size() - 1 else items[0]
		control.focus_mode = Control.FOCUS_ALL
		control.focus_previous = previous_control.get_path()
		control.focus_next = next_control.get_path()
		if axis == AXIS_HORIZONTAL:
			control.focus_neighbor_left = previous_control.get_path()
			control.focus_neighbor_right = next_control.get_path()
			control.focus_neighbor_top = control.get_path()
			control.focus_neighbor_bottom = control.get_path()
		else:
			control.focus_neighbor_top = previous_control.get_path()
			control.focus_neighbor_bottom = next_control.get_path()
			control.focus_neighbor_left = control.get_path()
			control.focus_neighbor_right = control.get_path()


static func grab_preferred(preferred: Control, fallback_controls: Array[Control] = []) -> void:
	if _can_focus(preferred):
		preferred.grab_focus()
		return
	grab_first_available(fallback_controls)


static func grab_first_available(controls: Array[Control]) -> void:
	for control in _filter_focusable_controls(controls):
		if _can_focus(control):
			control.grab_focus()
			return


static func _filter_focusable_controls(controls: Array[Control]) -> Array[Control]:
	var items: Array[Control] = []
	for control in controls:
		if control != null and is_instance_valid(control):
			items.append(control)
	return items


static func _can_focus(control: Control) -> bool:
	if control == null or not is_instance_valid(control):
		return false
	if not control.is_inside_tree() or not control.is_visible_in_tree():
		return false
	if control.focus_mode == Control.FOCUS_NONE:
		return false
	var button := control as BaseButton
	if button != null and button.disabled:
		return false
	return true