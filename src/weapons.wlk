import wollok.game.*
import utils.*
import directions.*
import screen.*

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
