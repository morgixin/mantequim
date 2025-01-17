extends Node2D

var cardBeingDragged
var screenSize
var isHoveringOnCard
var playerHandReference
var playerItemsHandReference
var playerReference
const COLLISION_MASK = 1
const COLLISION_MASK_SLOT = 2
const COLLISION_MASK_EQUIP = 4
const COLLISION_MASK_USE = 8
const COLLISION_MASK_DISCARD = 16
const COLLISION_MASK_MONSTER = 32

func _ready() -> void:
	screenSize = get_viewport_rect().size
	playerHandReference = $"../MaoJogador"
	playerItemsHandReference = $"../MaoEquipados"
	playerReference = $"../Jogador"
	get_tree().get_root().size_changed.connect(resize)
	
func resize() -> void:
	screenSize = get_viewport_rect().size

func _process(delta: float) -> void:
	if cardBeingDragged:
		var mouse_pos = get_global_mouse_position()
		cardBeingDragged.position = mouse_pos
		cardBeingDragged.position = Vector2(clamp(mouse_pos.x, 0, screenSize.x), clamp(mouse_pos.y, 0, screenSize.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check(COLLISION_MASK)
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
		var cardSlotFound = raycast_check(COLLISION_MASK_SLOT)
		var cardEquipFound = raycast_check(COLLISION_MASK_EQUIP)
		var cardUseFound = raycast_check(COLLISION_MASK_USE)
		var discardFound = raycast_check(COLLISION_MASK_DISCARD)
		var monsterFound = raycast_check(COLLISION_MASK_MONSTER)
		if cardSlotFound:
			playerHandReference.removeDaMao(cardBeingDragged)
			playerItemsHandReference.removeDaMao(cardBeingDragged)
			cardSlotFound.getNextStackIndex()
			cardBeingDragged.z_index = cardSlotFound.stack_index
			cardBeingDragged.position = cardSlotFound.position
			var random_degrees = randf_range(-10, 10)
			cardBeingDragged.rotation = deg_to_rad(
				random_degrees
			)
			cardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = true
		elif monsterFound and monsterFound.admiteCarta(cardBeingDragged):
			playerHandReference.removeDaMao(cardBeingDragged)
			playerItemsHandReference.removeDaMao(cardBeingDragged)
			cardBeingDragged.z_index = monsterFound.getNextStackIndex()
			cardBeingDragged.position = monsterFound.position
			var random_degrees = randf_range(-10, 10)
			cardBeingDragged.rotation = deg_to_rad(random_degrees)
			monsterFound.adicionarCartaSlot(cardBeingDragged)
			cardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = false
			
		elif cardUseFound and cardUseFound.admiteCarta(cardBeingDragged):
			playerHandReference.removeDaMao(cardBeingDragged)
			playerItemsHandReference.removeDaMao(cardBeingDragged)
			cardBeingDragged.z_index = cardUseFound.getNextStackIndex()
			cardBeingDragged.position = cardUseFound.position
			var random_degrees = randf_range(-10, 10)
			cardBeingDragged.rotation = deg_to_rad(random_degrees)
			cardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = false
			cardUseFound.addCartaUsada(cardBeingDragged)
			
		elif cardEquipFound and playerReference.admitirCarta(cardBeingDragged): 
			playerHandReference.removeDaMao(cardBeingDragged)
			cardBeingDragged.z_index = cardEquipFound.getNextStackIndex()
			cardBeingDragged.get_node("Area2D/CollisionShape2D").disabled = false
			playerItemsHandReference.addMao(cardBeingDragged)
			
			
		elif discardFound:
			var cartaParaDescarte = cardBeingDragged
			playerHandReference.removeDaMao(cardBeingDragged)
			cartaParaDescarte.get_node("Area2D/CollisionShape2D").disabled = true
			var toDiscard =  await discardFound.confirmaDescarte()
			playerItemsHandReference.removeDaMao(cartaParaDescarte)
			if $"..".useCardSlot:
				$"..".useCardSlot.removerDaMao(cartaParaDescarte)
			if $"..".monsterCardSlot:
				$"..".monsterCardSlot.removerCartaSlot(cardBeingDragged)
			if toDiscard:
				var tween_hide = get_tree().create_tween()
				
				tween_hide.tween_property(cardBeingDragged, "scale", Vector2(0,0), 0.35)
				await tween_hide.finished
				cardBeingDragged.hide()
			else:
				cartaParaDescarte.get_node("Area2D/CollisionShape2D").disabled = false
				playerHandReference.addMao(cartaParaDescarte)
		else:
			playerItemsHandReference.removeDaMao(cardBeingDragged)
			if $"..".useCardSlot:
				$"..".useCardSlot.removerDaMao(cardBeingDragged)
			if $"..".monsterCardSlot:
				$"..".monsterCardSlot.removerCartaSlot(cardBeingDragged)
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
		var newCardHovered = raycast_check(COLLISION_MASK)
		if newCardHovered:
			highlight_card(newCardHovered, true)
		else:
			isHoveringOnCard = false
	
func highlight_card(card, hovered):
	if playerHandReference.maoJogador.has(card):
		if hovered:
			card.scale = Vector2(1.05, 1.05)
			card.z_index = 100
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
	
func raycast_check(collider: int):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collider
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null
	

	
