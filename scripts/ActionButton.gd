extends Button
class_name ActionButton

@export var action_type: Actions.Type;
var _c: Callable;

func setButton(c):
	if action_type == Actions.Type.GROUP:
		self.text = "Group Rule %s" % GroupRules.group_action.getCostString();
	if c is Callable:
		_c = c;
		self.visible = true;
	
func clearButton():
	_c = Callable();
	self.visible = false;
	self.disabled = false;
	
func action():
	_c.call();
