import weapons.*
import misc.*
import wollok.game.*
import utils.*
import directions.*
import screen.*

// Characters
class Character {
	var hp
	const maxHp = hp
	var weapon = noWeapon
	var property position
	var property image = null
	var property hpbar = null
	var property orientation = left
	
	method image() = image + orientation.letter() + ".png"
	
	//Para mostrar la vida por consola
	method hp() = hp
	
	method setWeapon(newWeapon) {weapon = newWeapon}
	method weapon() = weapon
	
	method die() { playScreen.levelCharacteristics().stopEvents() }
	
	method alive() = hp > 0
	
	method attack()
	
	method bulletCrash(damage) { self.removeLife(damage) }
	
	method buffCrash(buff) { buff.apply(self) }
	
	method removeLife(mount) {
		hp = (hp - mount).max(0)
		hpbar.refresh(hp)
		if (self.alive().negate()){
			self.die()
		}
	}
	
	method addLife(mount) { 
		hp = maxHp.min(hp + mount)
		hpbar.refresh(hp)
	}
	
	method win()
	
	method loadHPBar(){
		hpbar = new HPBar(hp = hp, position = self.hpBarPosition())
		game.addVisual(hpbar)
	}
	
	method hpBarPosition() = game.at(position.x(), game.height() - game.height() / 14)
	
	method movimiento(dir){
		if(self.estaEnLimite(dir) or self.hayODE(dir) )position = dir.nextPosition(position)
	}	
	
	method estaEnLimite(dir) = lvlDungeon.isInside(dir.nextPosition(position))
	method hayODE(dir)= lvlDungeon.dondeHayODE().any({posicion=>posicion==dir.nextPosition(position)})
		
	method chocar(){
		if(orientation.letter()=="L") position=position.left(-2)
		if(orientation.letter()=="R") position=position.right(-2)
		if(orientation.letter()=="U") position=position.up(-2)
		if(orientation.letter()=="D") position=position.down(-2)
		}
	
}

class Boss inherits Character {
	const dificulty
	
	var dying = false
	
	override method image() = "bosses/" + image + ".png"
	
	method start(){
		game.onTick(250, "autoAttack", {self.autoAttack()})
	}
	
	override method attack() {
		weapon.fire(position.left(1), left)
	}
	
	method autoAttack(){
		const probability = random.natural(0, 100)
		
		if (probability > self.minProbabilityForAttack()){
			self.attack()
		} 
	}
	
	method minProbabilityForAttack() = 60.min(self.canAttackFunction())
	
	method canAttackFunction() = (1.04 ** (- dificulty + 105) + 1).roundUp(0)
	
	// Life
	override method die(){
		super()
		if (dying.negate()){
			dying = true
			game.removeTickEvent("autoAttack")
			game.say(self, "Volvere mas fuerte...")
			game.schedule(3000, {
				game.removeVisual(self)
				door.spawn()
			})
		}
	}
	
	override method win() {}
}

class Player inherits Character {
	var jumping = false
	
	override method image() = "characters/" + super()
		
	override method die(){
		super()
		game.say(self, "Zzzzzz GG NO TEAM")
		game.schedule(2000, {playScreen.levelCharacteristics().end()})
	}
	
	
	override method attack() {
		weapon.fire(orientation.nextPosition(position), orientation)
	}
	

	method goTo(dir) {
		if( playScreen.levelCharacteristics().isInside(dir.nextPosition(position))){
			orientation = dir
			position = dir.nextPosition(position)
		}
	}
	
	method jump(){
        if ( playScreen.levelCharacteristics().isInside(orientation.nextPosition(orientation.nextPosition(position))) and jumping.negate()){
            jumping = true
            position = orientation.nextPosition(position).up(3)
            game.schedule(300, {
            	position = orientation.nextPosition(position).down(3)
            	jumping = false
            })
        } else if (jumping.negate()) {
            position = position.up(3)
            game.schedule(300, {
            	position = position.down(3)
            })
        }
    }
	
	override method win() {
		game.removeVisual(self)
		game.say(door, "GANE! SOY EL MEJOR!")
		game.schedule(1000, {playScreen.levelCharacteristics().end()})
	}
}

class Enemy inherits Character {
	
	const id
	const imagenesEnemys = ["enemy1.png","enemy2.png","enemy3.png","enemy4.png","enemy5.png"]
	
	override method image() = image
	method randomImage() {image = random.lista(imagenesEnemys)}
	
	override method die(){
		game.schedule(75,{game.removeVisual(self)})
		game.removeTickEvent("autoAttack"+id)
		game.removeTickEvent("movimiento"+id)
		lvlDungeon.removeEnemy(self)
		if(lvlDungeon.ningunEnemigo()) {trapDoor.spawn()}
		}
	method start(){
		game.onTick(750, "autoAttack"+id, {self.attack()})
		game.onTick(500, "movimiento"+id, {self.move()})
	}
	
	override method attack() =if(orientation.letter()=="L") weapon.fire(position.left(1), orientation) else weapon.fire(position.right(1), orientation)
	override method loadHPBar() {hpbar = new HPBar(hp = hp, position = self.hpBarPosition())}
	
	method move(){
		const dir = random.direccion()
		self.movimiento(dir)
		orientation = dir	
	}
	
	method spawn(){
		self.setWeapon(new Weapon(buff = 2))
		self.loadHPBar()
		self.randomImage()
		self.start()
		game.addVisual(self)
	}
	override method win(){}
}

class PlayerDungeon inherits Character {
	const frases = ["Casi abro los ojos", "Pero que facil", "A ver si se esfuerzan mas", "Habia enemigos??", "Que maletas que eran", "*Frase epica de victoria"]
	override method die(){
		hp = 0
		super()
		game.say(self, "Zzzzzz GG NO TEAM")
		game.schedule(1300, {playScreen.levelCharacteristics().end()})
	}
	
	
	method goTo(dir) {
		self.movimiento(dir)	
		if(lvlDungeon.estaEnLava(self.position()))self.die()
		if(dir.letter()=="R"){self.image("Character.png")
			orientation = dir
		}else{if(dir.letter()=="L"){self.image("Character_Alter.png") 
			orientation =dir
		}}
	}
	
	override method hpBarPosition() = game.at(position.x()+1, game.height() - game.height() / 14)
	override method attack() = if(orientation.letter()=="L") weapon.fire(position.left(1), orientation) else weapon.fire(position.right(1), orientation)
	override method image() = image
	override method win() {
		game.removeVisual(self)
		game.say(trapDoor, random.lista(frases))
		game.schedule(1000, {lvlDungeon.end()})
	}
	method jump(){}
}