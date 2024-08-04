
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "AH-1Z Viper"
ENT.Category = "[LVS] - Helicopters"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lfs_merydian/helicopters/ah1z/viper.mdl"
--ENT.MDL_DESTROYED = 	"models/lfs_merydian/helicopters/ah1z/gibs/viper_1.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 500

ENT.MaxVelocity = 2000

ENT.ThrustUp = 1.2
ENT.ThrustDown = 0.8
ENT.ThrustRate = 0.8

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1.2
ENT.TurnRateRoll = 1

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
	    sound = "^lfs_custom/merydian_mechanics/rotors_merged.wav",
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
	    sound = "^lfs_custom/merydian_mechanics/heli_engine_generic.wav",
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
	self:AddDT( "Bool", "LightsEnabled" )
	self:AddDT( "Bool", "SignalsEnabled" )
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
	weapon.Delay = 60 / 800
	weapon.HeatRateUp = 0.15
	weapon.HeatRateDown = 0.2
	weapon.StartAttack = function( ent )
		ent.GunSound = ent:StartLoopingSound("30MM_LOOP")
	end
	weapon.FinishAttack = function( ent )
		if !ent:WeaponsInRange() then return end
		ent:EmitSound("30MM_STOP")
		ent:StopLoopingSound( ent.GunSound )
	end
	
	
	weapon.Attack = function( ent )
		if !ent:WeaponsInRange() then
		
			ent:StopLoopingSound( ent.GunSound )
		
			return true
		end
		
		ent.GunSound = ent:StartLoopingSound("30MM_LOOP")
		
		local ID = ent:LookupAttachment( "muzzle" )
		local Muzzle = ent:GetAttachment ( ID )
		if not Muzzle then return end
		local effectdata = EffectData()
		effectdata:SetOrigin( Muzzle.Pos ) --( ent:LocalToWorld( Vector(250.005,0.804,-25.79) ) )
		effectdata:SetNormal( Muzzle.Ang:Forward() ) --( ent:GetForward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

 	 	ent.FireLeft = not ent.FireLeft	
		
	local trace = self:GetEyeTrace()
			
	local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= (trace.HitPos - Muzzle.Pos):GetNormalized()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_white"
		bullet.Force	= 10
		bullet.HullSize 	= 15
		bullet.Damage	= 14
		bullet.Velocity = 10000
		bullet.SplashDamage = 16
		bullet.SplashDamageRadius = 40
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "lvs_custom_30mm_impact", effectdata, true, true )
	end

		ent:LVSFireBullet( bullet )

		ent:TakeAmmo( 1 )
		
		
		--weapon.OnSelect = function( ent ) ent:EmitSound("lvs_custom/ah6/select_minigun.wav") end
	    weapon.OnOverheat = function( ent ) ent:EmitSound("30MM_STOP") end
		end
	
	weapon.OnThink = function( ent, active )
		ent:SetPoseParameterTurret()
	end
	
	self:AddWeapon( weapon )
	
	
	-- Hydras
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/missile.png")
	weapon.Ammo = 80
	weapon.Delay = 0.2
	weapon.HeatRateUp = 0
	weapon.Attack = function( ent )

	ent.FireLeft = not ent.FireLeft

	local Driver = ent:GetDriver()
	local Target = ent:GetEyeTrace().HitPos

	local projectile = ents.Create( "lvs_missile" )
		projectile:SetPos( ent:LocalToWorld( Vector(19.36,68.89 * (self.FireLeft and 1 or -1),-13.39) ) )
		projectile:SetAngles( ent:GetAngles() )
		projectile:SetParent( ent )
		projectile:Spawn()
		projectile:Activate()
		projectile:SetAttacker( IsValid( Driver ) and Driver or self )
		projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
		projectile:SetSpeed( ent:GetVelocity():Length() + 6000 )
		projectile:SetDamage( 400 )
		projectile:SetRadius( 250 )
		projectile:Enable()
		projectile:EmitSound("npc/waste_scanner/grenade_fire.wav")

		ent:TakeAmmo()
	end
	
	weapon.OnSelect = function( ent )
		--ent:EmitSound("lvs_custom/ah6/select_missile.wav")
	end
	self:AddWeapon( weapon )

end