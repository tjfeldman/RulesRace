extends Node

#since this is an event bus class, the signals will never be used within the class itself
@warning_ignore_start("unused_signal")

enum Movements {
	JAIL,
	ESCAPE,
	NONE
}

signal updated_escape_tickets(player: Player);

#Turn Events
signal start_turn();
signal end_turn();

#Action Events
signal roll_die_action(special: bool);
signal escape_jail_action();
signal gain_die_roll(special: bool);

#Move Events
signal player_moved(escapedFromPrison: bool);
signal player_reached_goal(player: Player);
