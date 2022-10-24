import wollok.game.*

// Utils
object random {
	method natural(from, to) = from.randomUpTo(to).truncate(0)
	method number() = self.natural(1, 10000000)
}

class CenterMessage {
	var message
	method position() = game.center()
	method text() = message
	method textColor() = "000000FF"
}

// Directions
object up {
	method nextPosition(pos) = pos.up(1)
}

object right {
	method nextPosition(pos) = pos.right(1)
}

object left {
	method nextPosition(pos) = pos.left(1)
}

object down {
	method nextPosition(pos) = pos.down(1)	
}

// Game Start / Settings
object engine {
	method startSetting() {
		game.title("HellHead") // HellFish
		game.width(50)
		game.height(25)  
		game.cellSize(30)
		self.keysGeneral()
	}
	method keysSettingPlayer(player) {
		keyboard.a().onPressDo({player.goTo(left)}) 
		keyboard.d().onPressDo({player.goTo(right)}) 
		keyboard.shift().onPressDo({player.attack()})
		keyboard.space().onPressDo({player.jump()})
	}
	method keysSettingPlayerAlter(player) {
		keyboard.left().onPressDo({player.goTo(left)}) 
		keyboard.right().onPressDo({player.goTo(right)}) 
		keyboard.control().onPressDo({player.attack()})
		keyboard.up().onPressDo({player.jump()})
	}
	method keysGeneral(){
		keyboard.r().onPressDo({scenario.restart()})
		keyboard.num(1).onPressDo({
			scenario.dificulty(1)
			scenario.restart()
		})
		keyboard.num(2).onPressDo({
			scenario.dificulty(2)
			scenario.restart()
		})
		keyboard.num(3).onPressDo({
			scenario.dificulty(3)
			scenario.restart()
		})
	}
}


// Scenario
object scenario {
	const playerBasePosition = game.at(game.center().x() - game.width() / 3, game.center().y() / 3)
	const bossBasePosition = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
	var difficulty = 1
	
	const xMin = game.width() / 10
	const xMax = game.width() - game.width() / 10
	const yMin = game.height() / 10
	const yMax = game.height() - game.height() / 10

	method estaAdentro(posicion) = self.limitX(posicion.x()) && self.limitY(posicion.y())
	
	method limitX(positionX) = positionX.between(xMin, xMax)
	method limitY(positionY) = positionY.between(yMin, yMax)
	
	method calculateBossLife() = random.natural(100, 300 * difficulty)
	
	method setGround(){
		game.boardGround("fondo1.png")
	}
	
	method load(){
		self.setGround()
		
		const player = new Player(hpMax = 100, position = playerBasePosition, image = "Character.png")
		if (dificulty == 3){
			player.setWeapon(crazyWeapon)
		}else {
			player.setWeapon(new Weapon(damage = 10, buff = 2))
		}
		engine.keysSettingPlayer(player)
		game.addVisual(player)
		player.loadHPBar()
		
		const boss = new Boss(
			hpMax = self.calculateBossLife(),
			position = bossBasePosition,
			dificulty = dificulty
		)
		boss.setWeapon(new Weapon(damage = 10, buff = 2))
		boss.randomImage()
		game.addVisual(boss)
		boss.start()
		boss.loadHPBar()
	}
	
	method end(){
		game.schedule(1000,
			{
				game.clear()
				game.addVisual(new CenterMessage(message = "GAME END"))
			}
		)
	}
	
	method restart(){
		game.clear()
		self.load()
	}
	
	method dificulty(lvl){
		difficulty = lvl
	}
}

object scenarioPVP {
	const playerBasePosition = game.at(game.center().x() - game.width() / 3, game.center().y() / 3)
	const alterPlayerBasePosition = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
	
	const xMin = game.width() / 10
	const xMax = game.width() - game.width() / 10
	const yMin = game.height() / 10
	const yMax = game.height() - game.height() / 10

	method estaAdentro(posicion) = self.limitX(posicion.x()) && self.limitY(posicion.y())
	
	method limitX(positionX) = positionX.between(xMin, xMax)
	method limitY(positionY) = positionY.between(yMin, yMax)
	
	method setGround(){
		game.boardGround("fondo1.png")
	}
	
	method load(){
		self.setGround()
		
		const player = new Player(hpMax = 100, position = playerBasePosition, image = "Character.png")
		player.setWeapon(new Weapon(damage = 10, buff = 2))
		engine.keysSettingPlayer(player)
		game.addVisual(player)
		
		const playerAlter = new Player(hpMax = 100, position = alterPlayerBasePosition, image = "Character_Alter.png", alter = true)
		playerAlter.setWeapon(new Weapon(damage = 10, buff = 2))
		engine.keysSettingPlayerAlter(playerAlter)
		game.addVisual(playerAlter)
	}
	
	method end(){
		game.schedule(1000,
			{
				game.clear()
				game.addVisual(new CenterMessage(message = "GAME END"))
			}
		)
	}
}

// Characters
class Character {
	var hpMax
	var weapon = null
	var property position
	var property image = null
	var property hpbar = null
	var hp = hpMax
	
	method image() = image
	
	//Para mostrar la vida por consola
	method hp() = hp
	
	method setWeapon(newWeapon) {weapon = newWeapon}
	
	method die() {
		game.removeVisual(hpbar)
	}
	
	method alive() = hp > 0
	
	method attack()
	
	method bulletCrash(damage) { self.removeLife(damage) }
	
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		hpbar.removeLife(mount)
		if (self.alive().negate()){
			self.die()
		} else {
			// game.say(self, hp.toString())
		}
	}
	
	method win()
	
	method characterName() = self.toString()
	
	method loadHPBar(){
		hpbar = new HPBar(hp = hp, hpMax = hpMax, position = self.hpBarPosition(), characterName = self.characterName())
		game.addVisual(hpbar)
	}
	
	method hpBarPosition() = game.at(position.x(), game.height() - game.height() / 10)
}

class Boss inherits Character {
	const dificulty // Dificulty 1 2 3
	
	const bosses = ["Boss_1.png", "Boss_2.png"]
	
	method randomImage() {
		image = bosses.get(random.natural(0, bosses.size() - 1))
	}
	
	method start(){
		game.onTick(750, "autoAttack", {self.autoAttack()})
		
	}
	
	override method attack() {
		weapon.fire(position.left(1), left)
	}
	
	method autoAttack(){
		const probability = random.natural(0, 100)
		if (probability > 75.min(100 / dificulty)){
			self.attack()
		} 
	}
	
	// Life
	override method die(){
		super()
		game.removeTickEvent("autoAttack")
		game.say(self, "Volvere mas fuerte...")
		game.schedule(5000, {
			game.removeVisual(self)
			door.spawn()
		})
	}
	
	override method win() {}
}

class Player inherits Character {
	const alter = false
	override method die(){
		super()
		game.say(self, "Zzzzzz GG NO TEAM")
		game.schedule(2000, {scenario.end()})
	}
	
	
	override method attack() {
		if (alter){
			weapon.fire(position.left(1), left)
		}else {
			weapon.fire(position.right(1), right)
		}
		
	}
	

	method goTo(dir) {
		if( scenario.estaAdentro(dir.nextPosition(position)) ){
			position = dir.nextPosition(position)
		}
	}
	
	method jump(){
        if ( scenario.estaAdentro(right.nextPosition(position.right(1))) ){
            position = position.up(3).right(1)
            game.schedule(300, {position = position.down(3).right(1)})
        } else {
            position = position.up(3)
            game.schedule(300, {position = position.down(3)})
        }
    }
	
	override method win() {
		game.removeVisual(self)
		game.say(door, "GANE! SOY EL MEJOR!")
		game.schedule(1000, {scenario.end()})
	}
}

// Misc
// Weapon and Bullet
class Weapon {
	const damage
	const buff
	const bulletImage = "Fireball.png"
	
	method calculateDamage() = damage * buff
	// method image() = bulletImage
	
	method fire(startPosition, orientation){
		const bullet = new Bullet(
			position = startPosition,
			damage = self.calculateDamage(),
			image = bulletImage,
			orientation = orientation,
			id = random.number()
		)
		bullet.startPath()
	}
}

object crazyWeapon inherits Weapon(damage = 20, buff = 1){
	override method fire(startPosition, _){
		const probability = random.natural(0, 100)
		var orientation = null
		if (probability > 75){
			orientation = up
		} else if (probability > 50){
			orientation = left
		} else if (probability > 25){
			orientation = right
		} else {
			orientation = down
		} 
		const bullet = new Bullet(
			position = startPosition,
			damage = self.calculateDamage(),
			image = bulletImage,
			orientation = orientation,
			id = random.number()
		)
		bullet.startPath()
	}
}

class Bullet {
	const damage
	const orientation
	const id
	
	const image
	var property position
	
	method image() = image
	method position() = position
	
	method startPath(){
		game.addVisual(self)
		game.onCollideDo(self, { something =>
			something.bulletCrash(damage)
			self.destroy()
		})
		game.onTick(20, self.unicID(), {self.move()})
	}
	
	method unicID() = "bullet" + id.toString()
	
	method move() {
		if (self.onLimit()){
			position = orientation.nextPosition(position)
		} else {
			self.destroy()
		}
	}
	
	method onLimit() = scenario.estaAdentro(orientation.nextPosition(position))
	
	method destroy() {
		game.removeTickEvent(self.unicID())
		game.removeVisual(self)
	}
	
	method bulletCrash(_) {
		self.destroy()
	}
	
	method win() {}
}

// Door - WIN
object door{
	var property position
	
	method image() = "CaveDoor.png"
	
	method position() = position
	
	method spawn() {
		position = game.at(game.center().x() + game.width() / 3, game.center().y() / 3)
		game.addVisual(self)
		game.onCollideDo(self, {anything => anything.win()})
	}
}

// HP Bar
class HPBar{
	var hp
	var hpMax
	var characterName
	const position
	method removeLife(mount){
		hp = (hp - mount).max(0)
	}
	method text() = characterName + " - " +  hp.toString()
	method textColor() = "FFFFFFFF"
	method position() = position
	
	method hpLevel() = (15 * hp / hpMax).roundUp(0).min(15)
	
	method image() = "HPBar" + self.hpLevel().toString() + ".png"
}