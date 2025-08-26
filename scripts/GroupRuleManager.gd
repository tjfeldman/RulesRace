extends Control

@onready var group_rule_selector: CenterContainer = $GroupRuleSelector
@onready var whenLabel: Label = $WhenDisplay/Label
@onready var triggerLabel: Label = $TriggerDisplay/Label
@onready var effectLabel: Label = $EffectDisplay/Label

#set to -1 to represent None
var whenRule: GroupRules.When = GroupRules.When.NONE;
var triggerRule: GroupRules.Trigger = GroupRules.Trigger.NONE;
var effectRule: GroupRules.Effect = GroupRules.Effect.NONE;

const LABEL_TEXT = {
	GroupRules.Effect.MOVE_ONE: "Would you like to move 1 space forward?",
	GroupRules.Effect.GAIN_TICKET: "Would you like to gain 1 Escape Ticket?",
	GroupRules.Effect.REROLL_DIE: "Would you like to roll the die again?",
	GroupRules.Effect.ROLL_SPECIAL_DIE: "Would you like to roll the special die?",
	GroupRules.Effect.MOVE_TO_PLAYER_AHEAD: "Would you like to move to the player ahead?",
}

#TODO: Maybe change to Static Class

var cachePlayerAhead = null;

func _ready() -> void:
	group_rule_selector.visible = false;
	group_rule_selector.rules_updated.connect(_on_rules_updated);
	
func _on_background_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click"):
		group_rule_selector.visible = !group_rule_selector.visible;
		
func _on_rules_updated(whenRuleBtn: RuleButton, triggerRuleBtn: RuleButton, effectRuleBtn: RuleButton):
	whenLabel.text = whenRuleBtn.description;
	triggerLabel.text = triggerRuleBtn.description;
	effectLabel.text = effectRuleBtn.description;
	
	whenRule = whenRuleBtn.type;
	triggerRule = triggerRuleBtn.type;
	effectRule = effectRuleBtn.type;
	
func _can_benefit_from_effect(affectedPlayer: Player):
	match effectRule:
		GroupRules.Effect.MOVE_ONE:
			return !affectedPlayer.isInJail();
		GroupRules.Effect.MOVE_TO_PLAYER_AHEAD:
			return !affectedPlayer.isInJail() and PlayerManager.getPlayerAhead(affectedPlayer);
		_:
			return true;

func _trigger_effect(affectedPlayer: Player):
	match effectRule:
		GroupRules.Effect.MOVE_ONE:
			await affectedPlayer.movePlayerForward();
		GroupRules.Effect.GAIN_TICKET:
			affectedPlayer.addEscapeTicket();
		GroupRules.Effect.REROLL_DIE:
			Events.emit_signal("gain_die_roll", false);
		GroupRules.Effect.ROLL_SPECIAL_DIE:
			Events.emit_signal("gain_die_roll", true);
		GroupRules.Effect.MOVE_TO_PLAYER_AHEAD:
			await affectedPlayer.moveToPlayer(PlayerManager.getPlayerAhead(affectedPlayer));
			
func checkRollTrigger(roll: Variant):
	match [triggerRule, roll]:
		[GroupRules.Trigger.ROLL_PRISON, "Jail"]:
			return true;
		[GroupRules.Trigger.ROLL_ONE, 1]:
			return true;
		[GroupRules.Trigger.ROLL_TWO, 2]:
			return true;
		[GroupRules.Trigger.ROLL_THREE, 3]:
			return true;
		_:
			return false;

#prompts the player who triggered the rule to gain the benefit
func promptRuleEffect(scene: Node2D, player: Player):
	if not _can_benefit_from_effect(player):
		return; #no reason to prompt player for effect since they cannot benefit
		
	if !player.isBot():
		var confirmBox = preload("res://scenes/confirmRuleUsage.tscn");
		var confirm = confirmBox.instantiate();
		scene.add_child(confirm);
		confirm.setLabel(LABEL_TEXT[effectRule]);
		if await confirm.choice_choosen:
			await _trigger_effect(player);
	else:
		await get_tree().create_timer(0.5).timeout;
		await _trigger_effect(player);
