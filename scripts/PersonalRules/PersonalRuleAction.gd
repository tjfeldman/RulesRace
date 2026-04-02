extends Node
class_name PersonalRuleAction

var _player: Player;
var _target: Player;
var _description: String;

func _init(player: Player, target: Player, description: String) -> void:
	_player = player;
	_target = target;
	_description = description;

"""
GETTERS
"""
func get_player() -> Player: return _player;
func get_target() -> Player: return _target;
func get_description() -> String: return _description;
