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
	}
	method keysSettingPlayer(player) {
		// keyboard.w().onPressDo({player.goTo(up)})
		keyboard.a().onPressDo({player.goTo(left)}) 
		// keyboard.s().onPressDo({player.goTo(down)}) 
		keyboard.d().onPressDo({player.goTo(right)}) 
		keyboard.q().onPressDo({player.attack()})
		keyboard.space().onPressDo({player.jump()})
	}
}


// Scenario
object scenario {
	const playerBasePosition = game.at(game.center().x() - game.width() / 3, game.center().y())
	const bossBasePosition = game.at(game.center().x() + game.width() / 3, game.center().y())
	const dificulty = 1
	
	const xMin = 3
	const xMax = game.width() - 3
	const yMin = 5
	const yMax = game.height() - 10

	method estaAdentro(posicion) = self.limitX(posicion.x()) && self.limitY(posicion.y())
	
	method limitX(positionX) = positionX.between(xMin, xMax)
	method limitY(positionY) = positionY.between(yMin, yMax)
	
	method calculateBossLife() = random.natural(0, 200 * dificulty)
	
	method setGround(){
		game.boardGround("fondo1.png")
	}
	
	method load(){
		self.setGround()
		
		const player = new Player(hp = 100, position = playerBasePosition)
		player.setWeapon(new Weapon(damage = 10, buff = 2))
		engine.keysSettingPlayer(player)
		game.addVisual(player)
		
		const boss = new Boss(
			hp = self.calculateBossLife(),
			position = bossBasePosition,
			dificulty = dificulty
		)
		boss.setWeapon(new Weapon(damage = 10, buff = 2))
		boss.randomImage()
		game.addVisual(boss)
		boss.start()
	}
	
	method end(){
		game.schedule(5000,
			{
				game.clear()
				game.addVisual(new CenterMessage(message = "GAME END"))
			}
		)
	}
}

// Characters
class Character {
	var hp
	var weapon = null
	var property position
	
	method setWeapon(newWeapon) {weapon = newWeapon}
	
	method die()
	
	method alive() = hp > 0
	
	method attack()
	
	method bulletCrash(damage) { self.removeLife(damage) }
	
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		if (self.alive().negate()){
			self.die()
		} else {
			game.say(self, hp.toString())
		}
	}
	
	method win()
}

class Boss inherits Character {
	const dificulty // Dificulty 1 2 3
	var image = null
	const bosses = ["Boss_1.png", "Boss_2.png"]
	
	// Image Boss
	method image() = image
	
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
	// Image Character
	method image() = "Character.png"
	
	
	override method die(){
		game.say(self, "Zzzzzz GG NO TEAM")
		game.schedule(2000, {scenario.end()})
	}
	
	
	override method attack() {
		weapon.fire(position.right(1), right)
	}
	

	method goTo(dir) {
		if( scenario.estaAdentro(dir.nextPosition(position)) ){
			position = dir.nextPosition(position)
		}
	}
	
	method jump(){
		position = position.up(3).right(1)
		game.schedule(500, {position = position.down(3).right(1)})
	}
	
	override method win() {
		game.removeVisual(self)
		game.say(door, "GANE! SOY EL MEJOR!")
		game.schedule(2000, {scenario.end()})
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
		if (self.onLimit().negate()){
			position = orientation.nextPosition(position)
		} else {
			self.destroy()
		}
	}
	
	method onLimit() = scenario.estaAdentro(orientation.nextPosition(position)).negate()
	
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
	var property position = game.at(game.center().x() + game.width() / 3, game.center().y())
	
	method image() = "CaveDoor.png"
	
	method position() = position
	
	method spawn() {
		game.addVisual(self)
		game.onCollideDo(self, {anything => anything.win()})
	}
}
