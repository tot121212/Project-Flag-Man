extends StaticBody2D

@export var stats_component : StatsComponent

func take_damage(damage):
	stats_component.take_damage(damage)
