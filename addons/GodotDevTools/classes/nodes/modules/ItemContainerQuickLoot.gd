extends Module
class_name ItemContainerQuickLoot

##Module that allows the parent [ItemContainer] to be "Quicklooted".
##
##Requires a [CollisionShape3D] child to function as hitbox for where the interaction prompt shows.
##Quicklooting means that the player gets to see a simplified interface that only allows the player to take items from the container.
##Cannot be siblings with [ItemContainerInterface].
