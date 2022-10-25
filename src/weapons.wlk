import wollok.game.*
import utils.*
import directions.*
import screen.*

// Weapon and Bullet
class Weapon {
	var buff = 0
	const bulletType = fireball
	
	method calculateDamage() = bulletType.damage() * buff
	
	method fire(startPosition, orientation){
		const bullet = new Bullet(
			position = startPosition,
			damage = self.calculateDamage(),
			type = bulletType,
			orientation = orientation,
			id = random.number()
		)
		bullet.startPath()
	}
	
	method addBuff(mount){ buff += mount }
	method buff() = buff
}

object crazyWeapon inherits Weapon(buff = 5){
	override method fire(startPosition, _){
		super(startPosition, self.randomDirection())
	}
	
	method randomDirection(){
		const probability = random.natural(0, 100)
		if (probability > 75){
			return up
		} else if (probability > 50){
			return left
		} else if (probability > 25){
			return right
		} else {
			return down
		}
	}
}

object noWeapon inherits Weapon(buff = 0){
	override method fire(startPosition, orientation){}
}

class Bullet {
	const id
	const type
	const damage
	var property orientation
	var reboundCount = 0
	
	var property position
	
	method image() = type.imageName() + orientation.letter() + ".png"
	method position() = position
	
	method addRebound(mount) { reboundCount += mount }
	method rebound() = reboundCount
	
	method startPath(){
		game.addVisual(self)
		game.onCollideDo(self, { something =>
			something.bulletCrash(damage)
			type.specialAction(self)
			// self.destroy()
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
	
	method onLimit() = playScreen.estaAdentro(orientation.nextPosition(position))
	
	method destroy() {
		game.removeTickEvent(self.unicID())
		game.removeVisual(self)
	}
	
	method bulletCrash(_) {
		self.destroy()
	}
	
	method win() {}
	
	method buffCrash(_) {}
}

object fireball {
	method damage() = 10
	method maxCollide() = 1
	method imageName() = "bullets/Fireball"
	method specialAction(bullet) {
		bullet.addRebound(1)
		if (self.maxCollide() <= bullet.rebound()){
			bullet.destroy()
		}
	}
}

object cannonball {
	method damage() = 10
	method maxCollide() = 2
	method imageName() = "bullets/Cannonball"
	method specialAction(bullet) {
		bullet.addRebound(1)
		if (self.maxCollide() <= bullet.rebound()){
			bullet.destroy()
		} else {
			bullet.orientation(bullet.orientation().invert())
		}
	}
}

object manaball {
	method damage() = 10
	method maxCollide() = 1
	method imageName() = "bullets/Manaball"
	method specialAction(bullet) {
		bullet.addRebound(1)
		if (self.maxCollide() <= bullet.rebound()){
			bullet.destroy()
		} else {
			bullet.orientation(bullet.orientation().invert())
		}
	}
}