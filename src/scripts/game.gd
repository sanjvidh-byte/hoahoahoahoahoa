extends Node2D

@onready var timerText = $TimeLabel
@onready var topRow = $TopPotions
@onready var potionButtons = $Buttons

var potionNames = ["bluePotion", "pinkPotion", "purplePotion"]
var potionPics = {
	"bluePotion": preload("res://assets/img/bluepos.png.webp"),
	"pinkPotion": preload("res://assets/img/pinkpos.png.webp"),
	"purplePotion": preload("res://assets/img/purplepos.png.webp")
}

var recipeOrder = []
var secondsLeft = 20.0
var isPlaying = false
var recipeCard
var recipeTitle

var retryButton

var roundCount = 0
var totalRounds = 5

func _ready():
	randomize()
	makeRecipeCard()
	makePotionButtons()
	makeRetryButton()
	startGameNow()
	set_process(true)

func _process(t):
	runGameLoop(t)

func runGameLoop(t):
	if isPlaying:
		secondsLeft -= t
		if secondsLeft < 0:
			secondsLeft = 0
			
		timerText.text = "Time Left: " + str(int(secondsLeft)) + "s"
		if secondsLeft <= 0:
			endTheGame(false)

func makeRecipeCard():
	var screenWidth = get_viewport_rect().size.x
	recipeCard = ColorRect.new()
	recipeCard.color = Color(0.6, 0.5, 1.0, 0.8)
	recipeCard.size.x = 700
	recipeCard.size.y = 150
	recipeCard.position.x = (screenWidth - recipeCard.size.x) / 2
	recipeCard.position.y = 70
	add_child(recipeCard)
	move_child(recipeCard, 0)

	recipeTitle = Label.new()
	recipeTitle.text = "Potion Recipe"
	recipeTitle.add_theme_color_override("font_color", Color.WHITE)
	recipeTitle.add_theme_font_size_override("font_size", 32)
	recipeTitle.position.x = (recipeCard.size.x / 2) - 100
	recipeTitle.position.y = -10
	recipeCard.add_child(recipeTitle)

func makePotionButtons():
	var screenWidth = get_viewport_rect().size.x
	var count = 3
	var spacing = 150
	var totalWidth = spacing * (count - 1)
	var startX = (screenWidth - totalWidth) / 2
	var y = 600
	for i in range(potionButtons.get_child_count()):
		var btn = potionButtons.get_child(i)
		btn.position.x = startX + i * spacing
		btn.position.y = y
		btn.visible = i < 3
		btn.disabled = false
		btn.custom_minimum_size = Vector2(160, 160)
		if not btn.pressed.is_connected(onPotionClicked):
			btn.pressed.connect(onPotionClicked.bind(i))

func makeRetryButton():
	retryButton = Button.new()
	retryButton.text = "Try Again"
	retryButton.visible = false
	retryButton.add_theme_font_size_override("font_size", 40)
	retryButton.size.x = 300
	retryButton.size.y = 100
	add_child(retryButton)
	retryButton.pressed.connect(onRetryClicked)

func startGameNow():
	secondsLeft = 20.0
	roundCount = 0
	isPlaying = true
	timerText.text = "Time Left: 20s"
	makePotionOrder()
	showRecipePotions()
	showPotionButtons()
	recipeCard.visible = true
	topRow.visible = true
	potionButtons.visible = true
	retryButton.visible = false

func makePotionOrder():
	recipeOrder = []
	for i in range(totalRounds):
		var pick = randi() % potionNames.size()
		recipeOrder = recipeOrder + [potionNames[pick]]

func showRecipePotions():
	var y = recipeCard.position.y + (recipeCard.size.y / 2)
	var startX = recipeCard.position.x + 50
	var spacing = 120
	for i in range(topRow.get_child_count()):
		var pot = topRow.get_child(i)
		if i < recipeOrder.size():
			var name = recipeOrder[i]
			pot.texture = potionPics[name]
			pot.position.x = startX + spacing * i
			pot.position.y = y
			pot.visible = true
		else:
			pot.visible = false

func showPotionButtons():
	for i in range(3):
		var btn = potionButtons.get_child(i)
		var potionType = potionNames[i]
		var pic = potionPics[potionType]
		if btn is TextureButton:
			btn.normal_texture = pic
			btn.hover_texture = pic
			btn.pressed_texture = pic
			btn.disabled_texture = pic
		btn.visible = true
		btn.disabled = false

func onPotionClicked(i):
	if i < 0 or i >= potionNames.size():
		return
	if recipeOrder.size() > 0 and recipeOrder[0] == potionNames[i]:
		recipeOrder.remove_at(0)
	showRecipePotions()
	if recipeOrder.size() == 0:
		roundCount += 1
		if roundCount < totalRounds:
			makePotionOrder()
			showRecipePotions()
		else:
			endTheGame(true)

func endTheGame(win):
	isPlaying = false
	if win:
		timerText.text = "You win!"
	else:
		timerText.text = "Time's up! You lost!"
		recipeCard.visible = false
		topRow.visible = false
		potionButtons.visible = false
		retryButton.position.x = (get_viewport_rect().size.x - retryButton.size.x) / 2
		retryButton.position.y = (get_viewport_rect().size.y - retryButton.size.y) / 2
		retryButton.visible = true

func onRetryClicked():
	startGameNow()
