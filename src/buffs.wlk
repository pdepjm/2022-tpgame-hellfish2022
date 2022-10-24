import wollok.game.*
import screen.*
import directions.*
import utils.*

object buffRain {
	method start(){
		game.onTick(1500, "buffRain", {self.dropBuff()})
	}
	
	method stop(){
		game.removeTickEvent("buffRain")
	}
	
	method dropBuff(){
		const probability = random.natural(0, 100)
		if (probability > 75){
			const buff = new Buff(
				id = random.number(),
				type = moreAttack,
				position = self.randomPosition()
			)
			buff.startPath()
		} else if (probability > 50){
			const buff = new Buff(
				id = random.number(),
				type = heal,
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
	var life = 45 // 45 segundos
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
	
	method buffCrash() {}
}

object heal {
	method image() = "buffs/Buff1.png"
	method apply(character){
		character.addLife(10)
	}
}

object moreAttack {
	method image() = "buffs/Buff2.png"
	method apply(character){
		character.weapon().addBuff(2)	
	}
}