import wollok.game.*
import weapons.*
import engine.*
import utils.*
import characters.*
import directions.*

object screenManager {
	var property actualScreen = menu

	method switchScreen(newScreen) {
		game.clear()
		actualScreen = newScreen
		self.startScreen()
	}

	method startScreen() {
		background.image(actualScreen.background())
		game.addVisual(background)
		game.schedule(10, { actualScreen.setInputs()})
		actualScreen.show()
	}

}

object background {
	const position = game.origin()
	var property image = null
	
	method position() = position
}

class LevelButton {
	var level
	var property selected = false
	var property position = null

	method image() {
		return "menu/LEVEL" + level.levelNumber().toString() + self.selectionText() + ".png"
	}

	method levelNumber() = level.levelNumber()

	method selectionText() = if (menu.selectedButton().levelNumber() == level.levelNumber()) "H" else ""

	method startLevel() {
		playScreen.levelCharacteristics(level)
		screenManager.switchScreen(playScreen)
	}

}

class Screen {

	method show()

	method setInputs()

	method background()

}

object menu inherits Screen {
	var selectedButtonNumber = 0

	override method background() = "menu/menu_background.jpg"

	method selectedButton() = self.buttons().get(selectedButtonNumber)

	override method setInputs() {
		keyboard.backspace().onPressDo{ game.stop()}
		keyboard.enter().onPressDo{ self.selectedButton().startLevel()}
		// levels
		keyboard.down().onPressDo{ self.selectChange(1)}
		keyboard.s().onPressDo{ self.selectChange(1)}
		keyboard.up().onPressDo{ self.selectChange(-1)}
		keyboard.w().onPressDo{ self.selectChange(-1)}
	}

	method limitBetweenListSize(list, number) {
		return number.limitBetween(0, list.size() - 1)
	}

	method selectChange(delta) {
		selectedButtonNumber = self.limitBetweenListSize(self.buttons(), selectedButtonNumber + delta)
	}

	method buttons() {
		// return [ new LevelButton(level = level0), new LevelButton(level = level1), new LevelButton(level = level2) ]
		return [ new LevelButton(level = level0), new LevelButton(level = level1), new LevelButton(level = new LevelHistory(level = 1)) ]
	}

	override method show() {
		var nextPosition = game.center().left(11).down(3)
		self.buttons().forEach({ button =>
			button.position(nextPosition)
			game.addVisual(button)
			nextPosition = nextPosition.down(2)
		})
	}
}

object endScreen inherits Screen {
	override method show() {
		// game.addVisual(new CenterMessage(message = "GAME END"))
	}
	
	override method setInputs() {
		keyboard.enter().onPressDo{ self.backMenu() }
	}
	
	override method background() = "menu/end_background.jpg"
	
	method backMenu() {
		screenManager.switchScreen(menu)
	}
}

object playScreen inherits Screen {
	var property levelCharacteristics = level1
	
	const xMin = game.width() / 10
	const xMax = game.width() - game.width() / 10
	const yMin = game.height() / 10
	const yMax = game.height() - game.height() / 10

	method estaAdentro(posicion) = self.limitX(posicion.x()) && self.limitY(posicion.y())
	
	method limitX(positionX) = positionX.between(xMin, xMax)
	method limitY(positionY) = positionY.between(yMin, yMax)

	override method show() {
		levelCharacteristics.load()
		game.addVisual(levelCharacteristics.character1())
		game.addVisual(levelCharacteristics.character2())
		levelCharacteristics.specialActions()
	}
	
	method levelNumber() = levelCharacteristics.levelNumber()

	override method background() = levelCharacteristics.background()

	override method setInputs() {
		// PLAYER 1
		keyboard.a().onPressDo({levelCharacteristics.character1().goTo(left)}) 
		keyboard.d().onPressDo({levelCharacteristics.character1().goTo(right)}) 
		keyboard.s().onPressDo({levelCharacteristics.character1().attack()})
		keyboard.space().onPressDo({levelCharacteristics.character1().jump()})
		
		// Para Player 2 en modo PVP
		if (levelCharacteristics.bossLife() == 0){
			keyboard.left().onPressDo({levelCharacteristics.character2().goTo(left)}) 
			keyboard.right().onPressDo({levelCharacteristics.character2().goTo(right)}) 
			keyboard.control().onPressDo({levelCharacteristics.character2().attack()})
			keyboard.up().onPressDo({levelCharacteristics.character2().jump()})
		}
	}

}

class LevelCharacteristics {
	const character1Position = game.at(game.center().x() - game.width() / 3, game.center().y() / 3)
	const character2Position = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
	var property character1 = null
	var property character2 = null
	
	method levelNumber()
	method background()
	
	// No va a ser usado en los niveles PVP
	method bossLife()
	method bossImage()
	
	method generateCharacters()
	
	method load() {
		self.generateCharacters()
	}
	
	method end(){
		game.schedule(1000,{ screenManager.switchScreen(endScreen) })
	}
	
	method specialActions()
}

object level0 inherits LevelCharacteristics {
	override method levelNumber() = 0
	override method background() = "levels/LEVEL0.jpg"
	override method bossLife() = 0
	override method bossImage() = ""
	
	override method generateCharacters(){
		character1 = new Player(hp = 100, position = character1Position, image = "Character", orientation = right)
		character1.setWeapon(new Weapon(buff = 2))
		character1.loadHPBar()
		
		character2 = new Player(hp = 100, position = character2Position, image = "Character")
		character2.setWeapon(new Weapon(buff = 2))
		character2.loadHPBar()
	}
	
	override method specialActions() {}
}

object level1 inherits LevelCharacteristics {
	override method levelNumber() = 1
	override method background() = "levels/LEVEL1.jpg"
	override method bossLife() = random.natural(500, 3000)
	override method bossImage() = "BOSS1"
	
	override method generateCharacters() {
		character1 = new Player(hp = 100, position = character1Position, image = "Character", orientation = right)
		character1.setWeapon(new Weapon(buff = 2))
		character1.loadHPBar()
		
		character2 = new Boss(hp = self.bossLife(), position = character2Position, dificulty = self.levelNumber(), image = self.bossImage())
		character2.setWeapon(new Weapon(buff = 2))
		character2.loadHPBar()
	}
	override method specialActions() {
		character2.start()
	}
}

object level2 inherits LevelCharacteristics {
	override method levelNumber() = 2
	override method background() = "levels/LEVEL2.jpg"
	override method bossLife() = random.natural(1000, 5000)
	override method bossImage() = "BOSS2"
	
	override method generateCharacters() {
		character1 = new Player(hp = 100, position = character1Position, image = "Character", orientation = right)
		character1.setWeapon(new Weapon(buff = 2))
		character1.loadHPBar()
		
		character2 = new Boss(hp = self.bossLife(), position = character2Position, dificulty = self.levelNumber(), image = self.bossImage())
		character2.setWeapon(new Weapon(buff = 5))
		character2.loadHPBar()
	}
	override method specialActions() {
		character2.start()
	}
}

class LevelHistory inherits LevelCharacteristics {
	var property level = 1
	
	const backgroundsCount = 3
	const bossesCount = 2
	
	override method levelNumber() = 99
	override method background() = "levels/LEVEL" + self.selectionBackground() + ".jpg"
	
	method selectionBackground() = mod.calculate(backgroundsCount, level)
	method selectionBoss() = mod.calculate(bossesCount, level)
	override method bossImage() = "bosses/BOSS" + self.selectionBoss().toString() + ".png"
	
	override method bossLife() = random.natural(100 * level, 300 * level)
	
	override method generateCharacters() {
		character1 = new Player(hp = 100 * level, position = character1Position, image = "Character", orientation = right)
		character1.setWeapon(new Weapon(buff = 2 * level))
		character1.loadHPBar()
		
		character2 = new Boss(hp = self.bossLife(), position = character2Position, dificulty = self.levelNumber(), image = self.bossImage())
		character2.setWeapon(new Weapon(buff = 5* level))
		character2.loadHPBar()
	}
	
	override method specialActions() {
		character2.start()
	}
	
	override method end(){
		if (character1.alive()){
			game.schedule(1000,{
				playScreen.levelCharacteristics(new LevelHistory(level = playScreen.levelCharacteristics().level() + 1))
				screenManager.switchScreen(playScreen)
			})
		} else {
			super()
		}
	}
}