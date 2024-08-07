
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "AH-64D Apache"
ENT.Category = "[LVS] - Helicopters"

ENT.VehicleCategory = "Helicopters"
ENT.VehicleSubCategory = "Heli Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lvs_copters/dark/ah64/ah-64d_apache_longbow.mdl"
--ENT.MDL_DESTROYED = 	"models/lfs_merydian/helicopters/ah1z/gibs/viper_1.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 800

ENT.MaxVelocity = 2050

ENT.ThrustUp = 1.2
ENT.ThrustDown = 0.8
ENT.ThrustRate = 0.8

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1.1
ENT.TurnRateYaw = 1.1
ENT.TurnRateRoll = 1.1

ENT.ForceLinearDampingMultiplier = 1.4

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.GibModels = {
	"models/XQM/wingpiece2.mdl",
	"models/XQM/wingpiece2.mdl",
	"models/combine_apc_destroyed_gib04.mdl",
	"models/combine_apc_destroyed_gib03.mdl",
	"models/props_phx/misc/propeller2x_small.mdl",
	"models/props_phx/misc/propeller3x_small.mdl",
	"models/gibs/gunship_gibs_nosegun.mdl",
	"models/gibs/gunship_gibs_nosegun.mdl",
	"models/props_c17/TrapPropeller_Engine.mdl",
	"models/XQM/jettailpiece1medium.mdl",
	"models/XQM/pistontype1huge.mdl",
	"models/props_lab/reciever01b.mdl",
	"models/props_lab/reciever01c.mdl",
	"models/nova/jeep_seat.mdl",
	"models/container_chunk05.mdl",
	"models/combine_apc_destroyed_gib05.mdl",
	"models/xqm/jetbody2wingrootb.mdl",
}

ENT.EngineSounds = {
	{
	    sound = "lvs_copters/engine/rotor3.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =110,
		UseDoppler = true,
	},
	{
	    sound = "lvs_copters/engine/rpm2.wav",
		Pitch = 0,
		PitchMin = 0,
		PitchMax = 155,
		PitchMul = 100,
		Volume = 1,
		VolumeMin = 0,
		VolumeMax = 1,
		SoundLevel =105,
		UseDoppler = true,
	}
}

--ENT.FlyByAdvance = 1 -- how many second the flyby sound is advanced
--ENT.FlyBySound = "AH6_FLYBY" -- which sound to play on fly by

function ENT:OnSetupDataTables()
end

function ENT:GetAimAngles()
	local Gun = self:GetAttachment( self:LookupAttachment( "muzzle" ) )

	if not Gun then return end

	local trace = self:GetEyeTrace()

	local AimAngles = self:WorldToLocalAngles( (trace.HitPos - Gun.Pos):GetNormalized():Angle() )

	return AimAngles
end

function ENT:WeaponsInRange()
	local AimAngles = self:GetAimAngles()
	
	return math.abs( AimAngles.y ) < 102 and AimAngles.p < 62 and AimAngles.p > -22
end

function ENT:SetPoseParameterTurret()
	local AimAngles = self:GetAimAngles()

	self:SetPoseParameter("turret_yaw", -AimAngles.y )
	self:SetPoseParameter("turret_pitch", AimAngles.p )
end

function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 1200
	weapon.Delay = 60 / 600
	weapon.HeatRateUp = 0.15
	weapon.HeatRateDown = 0.17
	weapon.StartAttack = function( ent )
		if not IsValid( self.SoundEmitter ) then
			local ID = self:LookupAttachment( "muzzle" )
			local Attachment = self:GetAttachment( ID )
			self.SoundEmitter = self:AddSoundEmitter( self:WorldToLocal( Attachment.Pos ), "2A42_LOOP", "2A42_LOOP" )
			self.SoundEmitter:SetSoundLevel( 95 )
		end

		self.SoundEmitter:Play()
	end
	
	weapon.FinishAttack = function( ent)
		if IsValid( self.SoundEmitter ) then
			self.SoundEmitter:Stop()
			self:EmitSound( "2A42_STOP" )
		end
	end
	
	
	weapon.Attack = function( ent )
	
		if !ent:WeaponsInRange() then
		
			self.SoundEmitter:Stop()
			--self:EmitSound( "2A42_STOP" )
		
			return true
		end
		
		self.SoundEmitter:Play()
		
		local ID = ent:LookupAttachment( "muzzle" )
		local Muzzle = ent:GetAttachment ( ID )
		if not Muzzle then return end
		local effectdata = EffectData()
		effectdata:SetOrigin( Muzzle.Pos )
		effectdata:SetNormal( Muzzle.Ang:Forward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

 	 	ent.FireLeft = not ent.FireLeft
		
		local trace = self:GetEyeTrace()
			
		local bullet = {}
		bullet.Src 	= Muzzle.Pos --( ent:LocalToWorld( Vector(250.005,0.804,-25.79) ) )
		bullet.Dir 	= (trace.HitPos - Muzzle.Pos):GetNormalized()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_white"
		bullet.Force	= 15000
		bullet.HullSize 	= 15
		bullet.Damage	= 28
		bullet.Velocity = 10000
		bullet.SplashDamage = 25
		bullet.SplashDamageRadius = 110
		bullet.SplashDamageType = DMG_BLAST
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "lvs_custom_30mm_impact", effectdata, true, true )
	end

		ent:LVSFireBullet( bullet )

		ent:TakeAmmo( 1 )
		
		
		weapon.OnSelect = function( ent ) ent:EmitSound("weapons/shotgun/shotgun_cock.wav") end
	    weapon.OnOverheat = function( ent ) ent:EmitSound("MI28_30MM_STOP") end
		end
		
	weapon.OnThink = function( ent, active )
		ent:SetPoseParameterTurret()
	end
		
		self:AddWeapon( weapon )
	
	
	-- rockets
	local weapon = {}
		weapon.Icon = Material("lvs/weapons/rocket.png")
	weapon.Ammo = 50
	weapon.Delay = 0.2
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	
	weapon.Attack = function( ent )

		local pod = ent:GetDriverSeat()
		if not IsValid( pod ) then return end
		
		ent.FireLeft = not ent.FireLeft
			
		local bullet = {}
		bullet.Src 	= ( ent:LocalToWorld( Vector(31.55,85.11 * (self.FireLeft and 1 or -1),-106.15) ) )
		bullet.Dir 	= ent:GetForward()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_missile"
		bullet.Force	= 10000
		bullet.HullSize 	= 15
		bullet.Damage	= 400
		bullet.Velocity = 6000
		bullet.SplashDamage = 200
		bullet.SplashDamageRadius = 300
		bullet.SplashDamageType = DMG_BLAST
		bullet.Attacker 	= ent:GetDriver()
		
		ent:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
		
		bullet.Callback = function(att, tr, dmginfo)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "lvs_explosion_small", effectdata, true, true )
	end

		ent:LVSFireBullet( bullet )

		ent:TakeAmmo( 1 )
		
		
		weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	   -- weapon.OnOverheat = function( ent ) ent:EmitSound("MI28_30MM_STOP") end
		end
		self:AddWeapon( weapon )
	
	
	local weapon = {}
		weapon.Icon = Material("lvs/weapons/hellfire.png")
	weapon.Ammo = 15
	weapon.Delay = 0.5
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	
	weapon.Attack = function( ent )

		local pod = ent:GetDriverSeat()
		if not IsValid( pod ) then return end
		
		ent.FireLeft = not ent.FireLeft
			
		local bullet = {}
		bullet.Src 	= ( ent:LocalToWorld( Vector(29.86,55.48 * (self.FireLeft and 1 or -1),-112.27) ) )
		bullet.Dir 	= ent:GetForward()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_missile"
		bullet.Force	= 10000
		bullet.HullSize 	= 15
		bullet.Damage	= 600
		bullet.Velocity = 3000
		bullet.SplashDamage = 400
		bullet.SplashDamageRadius = 500
		bullet.SplashDamageType = DMG_BLAST
		bullet.Attacker 	= ent:GetDriver()
		
		ent:EmitSound( "weapons/stinger_fire1.wav" )
		
		bullet.Callback = function(att, tr, dmginfo)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "lvs_explosion_bomb", effectdata, true, true )
	end

		ent:LVSFireBullet( bullet )

		ent:TakeAmmo( 1 )
		
		
		weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	   -- weapon.OnOverheat = function( ent ) ent:EmitSound("MI28_30MM_STOP") end
		end
		self:AddWeapon( weapon )
end

sound.Add( {
	name = "2A42_LOOP",
	channel = CHAN_auto,
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