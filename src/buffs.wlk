import wollok.game.*
import screen.*
import directions.*
import utils.*
import weapons.*

object buffRain {
	method start(){ game.onTick(1500, "buffRain", { self.dropBuff() }) }
	
	method stop(){ game.removeTickEvent("buffRain") }
	
	method dropBuff(){
		const probability = random.natural(0, 100)
		var type = noBuff
		if (probability > 90){
			type = new AtarashiiWeapon(bulletType = cannonball)
		} else if (probability > 80){
			type = new AtarashiiWeapon(bulletType = manaball)
		} else if (probability > 75){
			type = moreAttack
		} else if (probability > 50){
			type = heal
		} else if (probability > 45){
			type = new AtarashiiWeapon(bulletType = fireball)
		}
		
		if (probability > 50){
			const buff = new Buff(
				id = random.number(),
				type = type,
				position = self.randomPosition()
			)
			buff.startPath()
		}
	}
	
	method randomPosition() {
		const positionX = random.natural(playScreen.levelCharacteristics().xMin(), playScreen.levelCharacteristics().xMax())
		const position = game.at(positionX, playScreen.levelCharacteristics().yMax())
		if (playScreen.levelCharacteristics().isInside(position)){
			return position
		} else {
			return self.randomPosition()
		}
	}
}

class Buff {
	const id
	var life = 20 // 10 segundos <== 20 / 2s (onTick 200)
	var type
	var property position
	
	method image() = type.image()
	
	method startPath(){
		game.addVisual(self)
		game.onCollideDo(self, { something =>
			something.buffCrash(type)
			self.destroy()
		})
		game.onTick(200, self.unicID(), {self.move()})
	}
	
	method unicID() = "buff" + id.toString()
	
	method move() {
		if (self.onLimits() and self.onCharacterYPosition().negate()){
			position = down.nextPosition(position)
		} else {
			self.reduceLife()
		}
	}
	
	method onLimits() = playScreen.levelCharacteristics().isInside(down.nextPosition(position))
	
	method onCharacterYPosition() = down.nextPosition(position).y() < game.center().y() / 3 
	
	method reduceLife(){
		life -= 1
		if (life <= 0){
			self.destroy()
		}
	}
	
	method destroy() {
		game.removeTickEvent(self.unicID())
		game.removeVisual(self)
	}
	
	method buffCrash(_) {}
	method bulletCrash(_) {}
}

object heal {
	method image() = "buffs/Buff1.png"
	method apply(character){
		character.addLife(50)
	}
}

object moreAttack {
	method image() = "buffs/Buff2.png"
	method apply(character){
		character.weapon().addBuff(2)	
	}
}

class AtarashiiWeapon {
	var property bulletType
	method image() = bulletType.imageName() + down.letter() + ".png"
	method apply(character){
		character.setWeapon(new Weapon(buff = character.weapon().buff(), bulletType = bulletType))
	}
}

object noBuff {
	method image() = ""
	method apply(character){}
}