@abstract
extends Node3D
class_name Hittable

signal got_hit(dmg_amount : float)

@abstract func hit(damage : float, from_point : Vector3, knockback : float)
