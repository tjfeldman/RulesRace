extends Node

enum OfficeChoice {Ticket, Dice, Rule};

signal office_choice_selected(choice: OfficeChoice);
signal escape_jail_with_ticket(choice: bool);
signal updated_escape_tickets(player: Player);
