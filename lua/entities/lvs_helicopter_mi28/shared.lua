
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "Mi-28N \"Havoc\""
ENT.Category = "[LVS] - Helicopters"

ENT.VehicleCategory = "Helicopters"
ENT.VehicleSubCategory = "Heli Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lvs_copters/bf4/mi28/havok.mdl"
--ENT.MDL_DESTROYED = 	"models/lfs_merydian/helicopters/ah1z/gibs/viper_1.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 800

ENT.MaxVelocity = 2150

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
	
	return math.abs( AimAngles.y ) < 92 and AimAngles.p < 62 and AimAngles.p > -22
end

function ENT:SetPoseParameterTurret()
	local AimAngles = self:GetAimAngles()

	self:SetPoseParameter("turret_yaw", -AimAngles.y )
	self:SetPoseParameter("turret_pitch", AimAngles.p )
end

function ENT:InitWeapons()
local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 1000
	weapon.Delay = 60 / 700
	weapon.HeatRateUp = 0.15
	weapon.HeatRateDown = 0.17
	weapon.StartAttack = function( ent )
		ent.GunSound = ent:StartLoopingSound("2A42_LOOP")
	end
	
	weapon.FinishAttack = function( ent )
		if !ent:WeaponsInRange() then return end
		ent:EmitSound("2A42_STOP")
		ent:StopLoopingSound( ent.GunSound )
	end
	
	
	weapon.Attack = function( ent )
	
		if !ent:WeaponsInRange() then
		
			ent:StopLoopingSound( ent.GunSound )
		
			return true
		end
		
		ent.GunSound = ent:StartLoopingSound("2A42_LOOP")
	
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
	weapon.Ammo = 40
	weapon.Delay = 0.2
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	
	weapon.Attack = function( ent )

		local pod = ent:GetDriverSeat()
		if not IsValid( pod ) then return end
		
		ent.FireLeft = not ent.FireLeft
			
		local bullet = {}
		bullet.Src 	= ( ent:LocalToWorld( Vector(19.36,80.89 * (self.FireLeft and 1 or -1),45.39) ) )
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
	weapon.Icon = Material("lvs/weapons/missile.png")
	weapon.Ammo = 10
	weapon.Delay = 0 -- this will turn weapon.Attack to a somewhat think function
	weapon.HeatRateUp = -0.5 -- cool down when attack key is held. This system fires on key-release.
	weapon.HeatRateDown = 0.25
	weapon.Attack = function( ent )
		local T = CurTime()

		if IsValid( ent._Missile ) then
			if (ent._nextMissleTracking or 0) > T then return end

			ent._nextMissleTracking = T + 0.1 -- 0.1 second interval because those find functions can be expensive

			ent._Missile:FindTarget( ent:GetPos(), ent:GetForward(), 30, 7500 )

			return
		end

		local T = CurTime()

		if (ent._nextMissle or 0) > T then return end

		ent._nextMissle = T + 0.5

		ent._swapMissile = not ent._swapMissile

		local Pos = Vector( 90, (ent._swapMissile and -104 or 104), -32 )

		local Driver = self:GetDriver()

		local projectile = ents.Create( "lvs_missile" )
		projectile:SetPos( ent:LocalToWorld( Pos ) )
		projectile:SetAngles( ent:LocalToWorldAngles( Angle(0,ent._swapMissile and 2 or -2,0) ) )
		projectile:SetParent( ent )
		projectile:Spawn()
		projectile:Activate()
		projectile:SetAttacker( IsValid( Driver ) and Driver or self )
		projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )

		ent._Missile = projectile

		ent:SetNextAttack( CurTime() + 0.1 ) -- wait 0.1 second before starting to track
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent._Missile ) then return end

		local projectile = ent._Missile

		projectile:Enable()
		projectile:EmitSound( "weapons/stinger_fire1.wav", 125 )
		ent:TakeAmmo()

		ent._Missile = nil

		local NewHeat = ent:GetHeat() + 0.75

		ent:SetHeat( NewHeat )
		if NewHeat >= 1 then
			ent:SetOverheated( true )
		end
	end
	weapon.OnSelect = function( ent ) ent:EmitSound("physics/metal/weapon_impact_soft3.wav") end
	weapon.OnOverheat = function( ent ) ent:EmitSound("lvs/overheat.wav") end
	self:AddWeapon( weapon )
end