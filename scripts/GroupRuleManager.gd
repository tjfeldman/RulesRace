extends Control

@onready var group_rule_selector: CenterContainer = $GroupRuleSelector
@onready var whenLabel: Label = $WhenDisplay/Label
@onready var triggerLabel: Label = $TriggerDisplay/Label
@onready var effectLabel: Label = $EffectDisplay/Label

#set to -1 to represent None
var whenRule: GroupRules.When = GroupRules.When.NONE;
var triggerRule: GroupRules.Trigger = GroupRules.Trigger.NONE;
var effectRule: GroupRules.Effect = GroupRules.Effect.NONE;

func _ready() -> void:
	group_rule_selector.visible = false;
	group_rule_selector.rules_updated.connect(_on_rules_updated);
	Events.confirm_rule_effect.connect(_trigger_effect);
	
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

func _trigger_effect(affectedPlayer: Player, choice: bool):
	match [effectRule, choice]:
		[GroupRules.Effect.MOVE_ONE, true]:
			await affectedPlayer.movePlayerForward();
			Events.emit_signal("player_moved", Events.Movements.None);
		_:
			Events.emit_signal("declined_rule_effect");
			
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
func promptRuleEffect(player: Player):
	if !player.isBot():
		var confirmBox = preload("res://scenes/confirmRuleUsage.tscn");
		var confirm = confirmBox.instantiate();
		#confirm.setLabel();
		confirm.setAffectedPlayer(player);
		self.get_parent().add_child(confirm);
	else:
		Events.emit_signal("confirm_rule_effect", player, true);
