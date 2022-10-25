import wollok.game.*
import screen.*
import directions.*
import utils.*
import weapons.*

object buffRain {
	method start(){
		game.onTick(1500, "buffRain", {self.dropBuff()})
	}
	
	method stop(){
		game.removeTickEvent("buffRain")
	}
	
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
		const positionX = random.natural(playScreen.xMin(), playScreen.xMax())
		const position = game.at(positionX, playScreen.yMax())
		if (playScreen.estaAdentro(position)){
			return position
		} else {
			return self.randomPosition()
		}
	}
	
	method buffs() = []
	
	method randomBuff() {
		
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
		if (self.onLimit() and self.onCharacterYPosition().negate()){
			position = down.nextPosition(position)
		} else {
			self.reduceLife()
		}
	}
	
	method onLimit() = playScreen.estaAdentro(down.nextPosition(position))
	
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

class BuffType {
	method image()
	method apply(character)
}

object heal inherits BuffType {
	override method image() = "buffs/Buff1.png"
	override method apply(character){
		character.addLife(10)
	}
}

object moreAttack inherits BuffType {
	override method image() = "buffs/Buff2.png"
	override method apply(character){
		character.weapon().addBuff(2)	
	}
}

class AtarashiiWeapon inherits BuffType {
	var property bulletType
	override method image() = bulletType.imageName() + down.letter() + ".png"
	override method apply(character){
		character.setWeapon(new Weapon(buff = character.weapon().buff(), bulletType = bulletType))
	}
}

object noBuff inherits BuffType {
	override method image() = ""
	override method apply(character){}
}