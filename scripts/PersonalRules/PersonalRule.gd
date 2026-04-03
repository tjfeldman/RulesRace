extends Node
class_name PersonalRule

var _trigger: PersonalRules.Trigger;
var _condition: PersonalRules.Condition;
var _target: PersonalRules.Target;
var _effect: PersonalRules.Effect;

func _init(t: PersonalRules.Trigger, c: PersonalRules.Condition, r: PersonalRules.Target, e: PersonalRules.Effect):
	_trigger = t;
	_condition = c;
	_target = r;
	_effect = e;
	
"""
GETTERS
"""
func get_trigger() -> PersonalRules.Trigger:
	return _trigger;
	
func get_condition() -> PersonalRules.Condition:
	return _condition;
	
func get_target() -> PersonalRules.Target:
	return _target;
	
func get_effect() -> PersonalRules.Effect:
	return _effect;
	
func _to_string() -> String:
	return "Personal Rule: %s %s, %s %s"% \
		[PersonalRules.get_trigger_str(_trigger), \
		PersonalRules.get_condition_str(_condition), \
		PersonalRules.get_target_str(_target), \
		PersonalRules.get_effect_str(_effect)];
	
#TESTING
static func get_random_personal_rule():
	var t = PersonalRules.Trigger.PRISON;
	#var c = PersonalRules.Condition.values().pick_random();
	var c = PersonalRules.Condition.DISCARD_TICKET;
	var r = PersonalRules.Target.I;
	var e = PersonalRules.Effect.MOVE_ONE;
	return PersonalRule.new(t,c,r,e);
