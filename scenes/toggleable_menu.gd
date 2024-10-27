extends Control
class_name ToggleableMenu

var is_menu_open : bool
func set_is_menu_open(i : bool):
	is_menu_open = i
func get_is_menu_open():
	return is_menu_open

func open_menu(): # opens menu
	if not get_tree().is_paused():
		get_tree().set_pause(true)
	if not is_visible():
		visible = true

func close_menu(): # closes menu
	if get_tree().is_paused():
		get_tree().set_pause(false)
	if is_visible():
		visible = false

func toggle_menu(): # opens and  menu depending on whether it is open or closed
	if not get_is_menu_open():
		open_menu()
	else:
		close_menu()

func check_is_menu_open(i = is_visible): ## input a callable as extra if you want but it will use is_visible by default
	if i is Callable:
		if i.call():
			set_is_menu_open(true)
		else:
			set_is_menu_open(false)
	else:
		print("Did not input callable for %s" % check_is_menu_open)
