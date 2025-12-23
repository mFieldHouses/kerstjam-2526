extends AggressionModifier
class_name LineOfSightAggressionModifier

@export var outer_radius : float ##The radius between
@export var inner_radius : float

func get_aggression_factor(entity : Enemy) -> float:
	var _entity_to_player : Vector3 = entity.global_position - PlayerState.player_instance.global_position
	return float(entity.global_basis.z.angle_to(_entity_to_player) / PI * 180 < entity.behavior_configuration.field_of_view) * float(RaycastManager.is_ray_free(entity.global_position + Vector3(0.0, 0.5, 0.0), PlayerState.player_instance.global_position + Vector3(0.0, 0.5, 0.0), 1, true))
