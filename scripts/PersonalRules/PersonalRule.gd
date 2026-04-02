extends Node
class_name PersonalRule

var _trigger: PersonalRules.Trigger;
var _condition: PersonalRules.Condition;

func _init(t: PersonalRules.Trigger, c: PersonalRules.Condition):
	_trigger = t;
	_condition = c;
	
"""
GETTERS
"""
func get_trigger() -> PersonalRules.Trigger:
	return _trigger;
	
func get_condition() -> PersonalRules.Condition:
	return _condition;
	
func _to_string() -> String:
	return "Personal Rule: %s %s"%[PersonalRules.get_trigger_str(_trigger), PersonalRules.get_condition_str(_condition)];
	
#TODO: Temporary
static func get_random_personal_rule():
	var t = PersonalRules.Trigger.SAME_SPACE;
	var c= PersonalRules.Condition.values().pick_random();
	return PersonalRule.new(t,c);
