drawBuffs();

if (!global.debug) return
var _stats = [
	"player health " + string(global.player.health),
	"player max health " + string(global.player.maxHealth),
	"player default max health " + string(global.player.defaultMaxHealth),
	"player stamina " + string(global.player.stamina),
	"player max stamina " + string(global.player.maxStamina),
	"player default max stamina " + string(global.player.defaultMaxStamina),
	"player default total hunger " + string(global.player.defaultTotalHunger),
	"player current hunger " + string(global.player.currentHunger),
];

for(var i = 0; i < array_length(_stats); i ++) {
	draw_text(10, 20 + (30 * i), _stats[i]);
}