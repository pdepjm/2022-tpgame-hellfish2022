import wollok.game.*
import weapons.*
import engine.*
import utils.*
import characters.*
import directions.*
import buffs.*
import misc.*

object screenManager {
	var property actualScreen = menuScreen

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
		return "menu/LEVEL" + level.number().toString() + self.selectionText() + ".png"
	}

	method levelNumber() = level.number()

	method selectionText() = if (menuScreen.selectedButton().levelNumber() == level.number()) "H" else ""

	method startLevel() {
		playScreen.levelCharacteristics(level)
		screenManager.switchScreen(playScreen)
	}

}

class Screen {

	method show(){}

	method setInputs()

	method background()

}

object menuScreen inherits Screen {
	var selectedButtonNumber = 0

	override method background() = "menu/menu_background.jpg"

	method selectedButton() = self.buttons().get(selectedButtonNumber)

	override method setInputs() {
		keyboard.backspace().onPressDo{ game.stop() }
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
		return [
			new LevelButton(level = level0), 
			new LevelButton(level = new LevelHistory())
		]
	}

	override method show() {
		var nextPosition = game.center().left(11).down(4)
		self.buttons().forEach({ button =>
			button.position(nextPosition)
			game.addVisual(button)
			nextPosition = nextPosition.down(2)
		})
	}
}

object endScreen inherits Screen {
	override method setInputs() { keyboard.enter().onPressDo({ self.backMenu() }) }
	override method background() = "menu/end_background.jpg"
	method backMenu() { screenManager.switchScreen(menuScreen) }
}

object lossScreen inherits Screen {
	override method setInputs() { keyboard.enter().onPressDo({ self.backMenu() }) }
	override method background() = "menu/loss_background.jpg"
	method backMenu() { screenManager.switchScreen(menuScreen) }
}

object playScreen inherits Screen {
	var property levelCharacteristics = level0
	//movi los limites a las caracteristicas de lvl para que las balas funcionen bn
	override method show() {
		levelCharacteristics.load()
		levelCharacteristics.specialActions()
		game.addVisual(levelCharacteristics.character1())
		//game.addVisual(levelCharacteristics.character2())
	}
	
	method levelNumber() = levelCharacteristics.number()

	override method background() = levelCharacteristics.background()

	override method setInputs() {
		// PLAYER 1
		keyboard.a().onPressDo({levelCharacteristics.character1().goTo(left)}) 
		keyboard.d().onPressDo({levelCharacteristics.character1().goTo(right)}) 
		keyboard.shift().onPressDo({levelCharacteristics.character1().attack()}) //cambio a shift
		keyboard.space().onPressDo({levelCharacteristics.character1().jump()})
		
		// Para Player 2 en modo PVP
		if (self.isPVPLevel()){
			keyboard.left().onPressDo({levelCharacteristics.character2().goTo(left)}) 
			keyboard.right().onPressDo({levelCharacteristics.character2().goTo(right)}) 
			keyboard.control().onPressDo({levelCharacteristics.character2().attack()})
			keyboard.up().onPressDo({levelCharacteristics.character2().jump()})
		}}
	
	
	method isPVPLevel() = levelCharacteristics.bossLife() == 0	

}

class LevelCharacteristics {
	var property character1 = null
	var property character2 = void
	var property number = 1
	var ending = false
	
	method background() = "levels/LEVEL" + self.selectionBackground().toString() + ".jpg"
	method selectionBackground() = number
	
	method xMin() = game.width() / 10
	method xMax() = game.width() - game.width() / 10
	method yMin() = game.height() / 10
	method yMax() = game.height() - game.height() / 10

	method isInside(position) = self.limitX(position.x()) && self.limitY(position.y())
	
	method limitX(positionX) = positionX.between(self.xMin(), self.xMax())
	method limitY(positionY) = positionY.between(self.yMin(), self.yMax())
	
	
	// No va a ser usado en los niveles PVP
	method bossLife() = random.natural(100 * number, 200 * number)
	method bossImage()
	
	method character1StartPosition() = game.at(game.center().x() - game.width() / 3, game.center().y() / 3)
	method character2StartPosition() = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
	
	method generateCharacters() {
		character1 = new Player(hp = 100, position = self.character1StartPosition(), image = "Character", orientation = right)
		character1.setWeapon(new Weapon(buff = 2))
		character1.loadHPBar()
	}
	
	method load() {
		ending = false
		self.generateCharacters()
		buffRain.start()
	}
	
	method end(){
		game.schedule(1000,{ screenManager.switchScreen(self.showLastScreen()) })
	}
	
	method showLastScreen(){
		if (character1.alive().negate()){
			return lossScreen
		} else {
			return endScreen
		}
	}
	
	method specialActions() {
	
		game.addVisual(self.character2())
	}
	
	method stopEvents(){
		if (ending.negate()){
			ending = true
			buffRain.stop()
			character1.setWeapon(noWeapon)
			character2.setWeapon(noWeapon)
		}
	}
}

object level0 inherits LevelCharacteristics(number = 0) {

	
	
	override method bossLife() = 0
	override method bossImage() = ""
	
	override method generateCharacters(){
		super()
		character2 = new Player(hp = 100, position = self.character2StartPosition(), image = "CharacterInverted")
		character2.setWeapon(new Weapon(buff = 2))
		character2.loadHPBar()
	}
	
	override method end(){ game.schedule(1000,{ screenManager.switchScreen(endScreen) }) }
}

class LevelHistory inherits LevelCharacteristics {
	const backgroundsCount = 3
	const bossesCount = 2
	
	
	
	override method selectionBackground() = mod.calculate(backgroundsCount, number)
	method selectionBoss() = mod.calculate(bossesCount, number)
	
	override method bossImage() = "Boss" + self.selectionBoss().toString()
	
	override method bossLife() = random.natural(100 * number, 200 * number)
	
	override method generateCharacters() {
		super()
		character2 = new Boss(hp = self.bossLife(), position = self.character2StartPosition(), dificulty = number, image = self.bossImage())
		character2.setWeapon(new Weapon(buff = 1.1 * number))
		character2.loadHPBar()
	}
	
	override method specialActions() {
		super()
		character2.start()
	}
	
	override method end(){
		if (character1.alive()){
			game.schedule(1000,{
				playScreen.levelCharacteristics(lvlDungeon)
				//playScreen.levelCharacteristics(new LevelHistory(number = number + 1))
				screenManager.switchScreen(playScreen)
			})
		} else {
			super()
		}
	}
}

object lvlDungeon inherits LevelCharacteristics {
	const playerBasePosition = game.at(0,0)
	const enemys = []
	const objetoDelEntorno = []
	
	override method xMin() = 0
	override method xMax() = 24
	override method yMin() = 0
	override method yMax() = 13

	method estaEnLava(position) = (position.x().between(6, 25) && position.y().between(3, 5)) or (position.x().between(20, 25) && position.y().between(5, 14))
	
	
	override method background() = "fondo_2.png"
	override method load(){
		self.generateCharacters()	
		self.playerKeys(character1)	
		}
	
	override method specialActions(){
		5.times({i=>self.agregarEnemigo(i-1)})
		7.times({i=>self.agregarObjetoDelEntorno(i-1)})
	}
	
	override method generateCharacters(){		
		character1 = new PlayerDungeon(hp = 100, position = playerBasePosition, image = "Character.png")
		character1.setWeapon(new Weapon(buff = 2))
		character1.loadHPBar()
		//self.playerKeys(character1)
	}
	
	method playerKeys(character){
		keyboard.a().onPressDo({character.goTo(left)}) 
		keyboard.d().onPressDo({character.goTo(right)}) 
		keyboard.w().onPressDo({character.goTo(up)})
		keyboard.s().onPressDo({character.goTo(down)})
	}
	
	method agregarEnemigo(n){
		enemys.add(new Enemy(hp=random.natural(50,200), position=self.randomPosition(), id = random.number().toString() )) 
		enemys.get(n).spawn()
	}
	
	method agregarObjetoDelEntorno(n){
		objetoDelEntorno.add(new ObjetoDelEntorno(position=self.positionNotInLava()))
		objetoDelEntorno.get(n).spawn()
	}
	method dondeHayODE()= objetoDelEntorno.map({objeto=>objeto.position()})
	
	override method end(){
		if(character1.alive().negate())super() else{
		playScreen.levelCharacteristics(new LevelHistory(number = number + 2))
		screenManager.switchScreen(playScreen)} 
	}
	
	method removeEnemy(enemy) = enemys.remove(enemy) 
	method ningunEnemigo() = enemys.isEmpty()
	
	method randomPosition() = game.at(random.natural(1,24),random.natural(1,14))
	
	method positionNotInLava(){
		const newPosition = self.randomPosition()
		 return (if(self.estaEnLava(newPosition))self.positionNotInLava() else newPosition)
		}
	override method bossImage(){}
}




