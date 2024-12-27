extends Node2D

var cardBeingDragged
var screenSize
var isHoveringOnCard
var playerHandReference
const COLLISION_MASK = 1
const COLLISION_MASK_SLOT = 2

func _ready() -> void:
	screenSize = get_viewport_rect().size
	playerHandReference = $"../MaoJogador"

func _process(delta: float) -> void:
	if cardBeingDragged:
		var mouse_pos = get_global_mouse_position()
		cardBeingDragged.position = mouse_pos
		cardBeingDragged.position = Vector2(clamp(mouse_pos.x, 0, screenSize.x), clamp(mouse_pos.y, 0, screenSize.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			if cardBeingDragged:
				stop_drag()
			

func start_drag(card):
	cardBeingDragged = card
	card.scale = Vector2(1, 1)
	
func stop_drag():
	if (cardBeingDragged != null):
		cardBeingDragged.scale = Vector2(1.05, 1.05)
		var cardSlotFound = raycast_check_for_card_slot()
		print(cardSlotFound)
		if cardSlotFound:
			playerHandReference.removeDaMao(cardBeingDragged)
			cardBeingDragged.position = cardSlotFound.position
			cardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = true
		else:
			playerHandReference.addMao(cardBeingDragged)
		cardBeingDragged = null

func connect_card_signals(card):
	card.connect("hovered", hovered_on_card)
	card.connect("hoveredOff", hovered_off_card)
	
func hovered_on_card(card):
	if !isHoveringOnCard:
		isHoveringOnCard = true
		highlight_card(card, true)
	
func hovered_off_card(card):
	if !cardBeingDragged:
		highlight_card(card,false)
		var newCardHovered = raycast_check_for_card()
		if newCardHovered:
			highlight_card(newCardHovered, true)
		else:
			isHoveringOnCard = false
	
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1
	
	
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_ind = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var curr_card = cards[i].collider.get_parent()
		if curr_card.z_index > highest_z_ind:
			highest_z_card = curr_card
			highest_z_ind = highest_z_card.z_index
	
	return highest_z_card
	

func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null
	
