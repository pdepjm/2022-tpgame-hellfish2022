import weapons.*
import misc.*
import wollok.game.*
import utils.*
import directions.*
import screen.*

// Characters
class Character {
	var hp
	var weapon = null
	var property position
	var property image = null
	var property hpbar = null
	
	
	method image() = image
	
	//Para mostrar la vida por consola
	method hp() = hp
	
	method setWeapon(newWeapon) {weapon = newWeapon}
	
	method die()
	
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
	
	method loadHPBar(){
		hpbar = new HPBar(hp = hp, position = self.hpBarPosition(), characterName = "TEST")
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
		game.say(self, "Zzzzzz GG NO TEAM")
		game.schedule(2000, {playScreen.levelCharacteristics().end()})
	}
	
	
	override method attack() {
		if (alter){
			weapon.fire(position.left(1), left)
		}else {
			weapon.fire(position.right(1), right)
		}
		
	}
	

	method goTo(dir) {
		if( playScreen.estaAdentro(dir.nextPosition(position)) ){
			position = dir.nextPosition(position)
		}
	}
	
	method jump(){
        if ( playScreen.estaAdentro(right.nextPosition(position.right(1))) ){
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
		game.schedule(1000, {playScreen.levelCharacteristics().end()})
	}
}
