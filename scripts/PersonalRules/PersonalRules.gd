extends Node
class_name PersonalRules

"""
Enums
"""
enum Trigger {
	SAME_SPACE,
}

enum Condition{
	ROLL_ONE,
	ROLL_TWO,
	ROLL_THREE,
	ROLL_PRISON,
	ROLL_ESCAPE,
	SENT_JAIL,
}

enum Target{
	I,
}

enum Effect{
	MOVE_ONE,
}

"""
String Conversion
"""
const TRIGGER_STR: Array[String] = [
	"A player who is in the same space",
]

const CONDITION_STR: Array[String] = [
	"rolls a die and gets a 1",
	"rolls a die and gets a 2",
	"rolls a die and gets a 3",
	"rolls a die and gets jail",
	"rolls a die and gets escape",
	"is sent to prison"
]

const TARGET_STR: Array[String] = [
	"I",
]

const EFFECT_STR: Array[String] = [
	"moves one step forward",
]

static func get_trigger_str(t: Trigger) -> String: return TRIGGER_STR[t];
static func get_condition_str(c: Condition) -> String: return CONDITION_STR[c];
static func get_target_str(t: Target) -> String: return TARGET_STR[t];
static func get_effect_str(e: Effect) -> String: return EFFECT_STR[e];
