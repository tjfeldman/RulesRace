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
}

"""
String Conversion
"""
const TRIGGER_STR: Array[String] = [
	"A player who is in same space",
]

const CONDITION_STR: Array[String] = [
	"rolls a die and gets a 1",
	"rolls a die and gets a 2",
	"rolls a die and gets a 3",
	"rolls a die and gets jail",
	"rolls a die and gets escape",
]

static func get_trigger_str(t: Trigger) -> String: return TRIGGER_STR[t];
static func get_condition_str(c: Condition) -> String: return CONDITION_STR[c];
