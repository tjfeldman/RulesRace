extends Node

#since this is an event bus class, the signals will never be used within the class itself
@warning_ignore_start("unused_signal")

enum OfficeChoice {Ticket, Dice, Rule};
enum Movements {Jail, Escape, Tile, Office, Rule, Goal, None}

signal office_choice_selected(choice: OfficeChoice);
signal updated_escape_tickets(player: Player);

#Turn Events
signal start_turn(player: Player);
signal end_turn();

#Action Events
signal roll_die_action(special: bool);
signal escape_jail_action();
signal declined_rule_effect();

#Move Events
signal player_moved(movement: Movements);
