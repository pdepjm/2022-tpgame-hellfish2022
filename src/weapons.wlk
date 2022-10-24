import wollok.game.*
import utils.*
import directions.*
import screen.*

// Weapon and Bullet
class Weapon {
	const buff
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
	const damage
	const orientation
	const id
	
	const type
	var property position
	
	method image() = type.imageName() + orientation.letter() + ".png"
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
	
	method onLimit() = playScreen.estaAdentro(orientation.nextPosition(position))
	
	method destroy() {
		game.removeTickEvent(self.unicID())
		game.removeVisual(self)
	}
	
	method bulletCrash(_) {
		self.destroy()
	}
	
	method win() {}
}

object fireball {
	method damage() = 10
	method imageName() = "bullets/Fireball"
}