import wollok.game.*

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

object engine {
	method startSetting() {
		game.title("HellHead") // HellFish
		game.width(50)
		game.height(25)  
		game.cellSize(30) 
	}
	method keysSetting() {
		// keyboard.w().onPressDo({player.goTo(up)})
		keyboard.a().onPressDo({player.goTo(left)}) 
		// keyboard.s().onPressDo({player.goTo(down)}) 
		keyboard.d().onPressDo({player.goTo(right)}) 
		keyboard.q().onPressDo({player.attack()})
		keyboard.space().onPressDo({player.jump()})
	}
}


object random {
	method natural(from, to) = from.randomUpTo(to).truncate(0)
}

object scenario {
	const playerBasePosition = game.at(game.center().x() - game.width() / 3, game.center().y())
	const bossBasePosition = game.at(game.center().x() + game.width() / 3, game.center().y())
	const hpBoss = random.natural(0, 250)
	
	const xMin = 3
	const xMax = game.width() - 3
	const yMin = 5
	const yMax = game.height() - 10

	method estaAdentro(posicion) = self.limitX(posicion.x()) && self.limitY(posicion.y())
	
	method limitX(positionX) = positionX.between(xMin, xMax)
	method limitY(positionY) = positionY.between(yMin, yMax)
	
	
	method load(){
		player.startAt(playerBasePosition)
		player.setWeapon(new Weapon(damage = 10, buff = 2))
		game.addVisual(player)
		
		const boss = new Boss(hp = hpBoss, position = bossBasePosition, dificulty = 3)
		boss.setWeapon(new Weapon(damage = 10, buff = 2))
		boss.startAt(bossBasePosition)
		boss.randomBoss()
		game.addVisual(boss)
		boss.start()
		
		game.boardGround("fondo1.png")
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

class CenterMessage {
	var message
	method position() = game.center()
	method text() = message
	method textColor() = "000000FF"
}

class Boss {
	var hp
	var property position
	const bosses = ["Boss_1.png", "Boss_2.png"]
	var image = null
	var weapon = null
	const dificulty // Dificulty 1 2 3
	
	// Image Boss
	method image() = image
	
	method randomBoss() {
		image = bosses.get(random.natural(0, bosses.size() - 1))
	}
	
	method start(){
		game.onTick(750, "autoAttack", {self.autoAttack()})
	}
	
	method attack() {
		weapon.fire(position.left(1), left)
	}
	
	method autoAttack(){
		const probability = random.natural(0, 100)
		if (probability > 75.min(100 / dificulty)){
			self.attack()
		} 
	}
	
	// Weapon
	method setWeapon(newWeapon) {weapon = newWeapon}
	
	// Life
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		if (self.alive().negate()) {
			self.dead()
		} else {
			// self.animateHit()
		}
		game.say(self, hp.toString())
	}
	
	method alive() = hp > 0
	
	method dead(){
		game.removeTickEvent("autoAttack")
		game.say(self, "Volvere mas fuerte...")
		game.schedule(5000, {
			game.removeVisual(self)
			puerta.aparecer()
		})
	}
	
	method animateHit(){
		game.removeVisual(self)
		game.schedule(250, {game.addVisual(self)})
		game.schedule(500, {game.removeVisual(self)})
		game.schedule(750, {game.addVisual(self)})
		game.schedule(1000, {game.removeVisual(self)})
		game.schedule(1250, {game.addVisual(self)})
	}
	
	// Position
	method startAt(basePosition) {
		position = basePosition
	}
	
	// Polimorfismo
	method bulletCrash(damage){
		self.removeLife(damage)
	}
}


object player {
	var hp = 100
	var weapon = null
	
	var property position
	
	// Image Character
	method image() = "Character.png"
	
	// Life
	method addLife(mount) {hp = hp + mount}
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		game.say(self, hp.toString())
	}
	
	method alive() = hp > 0
	
	method die(){
		game.say(self, "Zzzzzz GG NO TEAM")
		game.schedule(2000, {scenario.end()})
	}
	
	// Weapon
	method setWeapon(newWeapon) {weapon = newWeapon}
	
	method attack() {
		weapon.fire(position.right(1), right)
	}
	
	// Position
	method startAt(basePosition) {
		position = basePosition
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
	
	// Polimorfismo
	method bulletCrash(damage){
		self.removeLife(damage)
		if (self.alive().negate()){
			self.die()
		}
	}
}

class Weapon {
	const damage
	const buff
	const bulletImage = "Fireball.png"
	var cont = random.natural(1, 100000)
	
	method damage() = damage * buff
	// method image() = bulletImage
	
	method fire(startPosition, orientation){
		const bullet = new Bullet(position = startPosition, damage = self.damage(), image = bulletImage, orientation = orientation, index = cont)
		bullet.start()
		cont++
	}
}

class Bullet {
	var position
	const damage
	const image
	var hit = false
	const orientation
	const index
	
	method image() = image
	method position() = position
	
	method start(){
		game.addVisual(self)
		game.onCollideDo(self, { something =>
			something.bulletCrash(damage)
			self.destroy()
		})
		game.onTick(20, self.unicID(), {self.move()})
	}
	
	method unicID() = "bullet" + index.toString()
	
	// Issue 1 - La bala no desaparece en onCollide
	method move() {
		if (hit.negate() && self.onLimit().negate()){
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
	
	method bulletCrash(a) {
		self.destroy()
	}
}


object puerta{
	
	var property position = game.at(game.center().x() + game.width() / 3, game.center().y())
	
	method image() = "CaveDoor.png"
	
	method position() = position
	
	method aparecer() {
		game.addVisual(self)
		game.onCollideDo(player, {_ => self.ganar()})
	}
	
	method ganar() {
		game.say(self, "GANE! SOY EL MEJOR!")
		game.schedule(5000, {scenario.end()})
	}
}
