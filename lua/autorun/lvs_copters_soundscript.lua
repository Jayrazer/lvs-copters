AddCSLuaFile()

sound.Add( {
	name = "M197_LOOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {90,100},
	sound = "^lvs_copters/weapons/m197_loop_750.wav"
} )

sound.Add( {
	name = "2A42_LOOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {90,100},
	sound = "^lvs_copters/weapons/2a42_loop.wav"
} )

sound.Add( {
	name = "2A42_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	pitch = {100},
	sound = {
	"^lvs_copters/weapons/2a42_lastshot1.wav",
	"^lvs_copters/weapons/2a42_lastshot2.wav",
	"^lvs_copters/weapons/2a42_lastshot3.wav"
	}
} )

sound.Add( {
	name = "GUNPODS_LOOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {90,100},
	sound = "^lvs_copters/weapons/m3_loop.wav"
} )

sound.Add( {
	name = "GUNPODS_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	pitch = {100},
	sound = "^lvs_copters/weapons/m3_lastshot.wav"
} )
