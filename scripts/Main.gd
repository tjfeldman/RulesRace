extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var dice: Sprite2D = $Dice
@onready var special_dice: Sprite2D = $SpecialDice
@onready var turn_status: Label = $TurnStatus
@onready var group_rule_manager: GroupRules = $GroupRuleManager

var _turn_manager: TurnManager;
var _personal_rule_manager: PersonalRuleManager;

"""
public functions
"""
func get_turn_player(): _turn_manager.get_turn_player();
func spend_die(): _turn_manager.spend_die();

func _ready() -> void:
	#start game
	Events.game_over.connect(_game_is_over);
	call_deferred("_start_game");
	
func _start_game():
	#add UI to HUD
	var offset = 0;
	#TODO: Should be handled elsewhere
	for player in PlayerManager.getPlayers():
		var playerUI = preload("res://scenes/playerUI.tscn");
		var ui = playerUI.instantiate();
		ui.assignedPlayer = player;
		hud.add_child(ui);
		ui.position += Vector2(0, offset);
		offset+= ui.size.y + 16;
		
	#create PersonalRuleManager
	_personal_rule_manager = PersonalRuleManager.new();
		
	#create TurnManager
	_turn_manager = TurnManager.new(turn_status, group_rule_manager, _personal_rule_manager);
	_turn_manager.startRace();
		
	#register dice events
	Events.roll_die.connect(_roll_dice);
	dice.dice_has_rolled.connect(_turn_manager._on_dice_has_rolled);
	special_dice.dice_has_rolled.connect(_turn_manager._on_dice_has_rolled);
	
func _roll_dice(special: bool):
	if special:
		dice.visible = false;
		special_dice.rollDie();
	else:
		special_dice.visible = false;
		dice.rollDie();

func _game_is_over():
	for child in self.get_children():
		child.visible = false;
	var results = preload("res://scenes/results.tscn");
	var results_ui = results.instantiate();
	self.get_parent().add_child(results_ui);
