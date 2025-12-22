extends Resource
class_name EnemyAIConfiguration

##Resource for describing enemy behavior

@export var field_of_view : float = 60.0

@export var aggression_threshold : float ##Value of the entity's aggression above which the enemy will show aggressive behavior towards its [param aggression_target].
@export var aggression_modifiers : Array[AggressionModifier] ##List of influences on the entity's aggression.
@export_flags("Player") var eligible_aggression_targets ##Entity types that this enemy can become aggressive towards.
