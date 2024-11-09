extends Node
#class_name Signal_Bus

signal change_orientation
signal projectile_collision #(self, collider, projectile_component.damage, knockback)
signal phantom_camera_follow_target(target)
