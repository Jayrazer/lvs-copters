
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "Mi-28NM \"Havoc\""
ENT.Category = "[LVS] - Helicopters"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lfs_merydian/helicopters/mi28/havok.mdl"
--ENT.MDL_DESTROYED = 	"models/lfs_merydian/helicopters/ah1z/gibs/viper_1.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 600

ENT.MaxVelocity = 2150

ENT.ThrustUp = 1.2
ENT.ThrustDown = 0.8
ENT.ThrustRate = 0.8

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1.1
ENT.TurnRateRoll = 1

ENT.ForceLinearDampingMultiplier = 1.4

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.GibModels = {
	"models/lfs_merydian/helicopters/mi28/gibs/havok.mdl",
	"models/combine_apc_destroyed_gib04.mdl",
	"models/combine_apc_destroyed_gib03.mdl",
	"models/props_phx/misc/propeller2x_small.mdl",
	"models/gibs/gunship_gibs_nosegun.mdl",
	"models/gibs/gunship_gibs_nosegun.mdl",
	"models/props_c17/TrapPropeller_Engine.mdl",
	"models/props_lab/reciever01b.mdl",
	"models/props_lab/reciever01c.mdl",
	"models/nova/jeep_seat.mdl",
}

ENT.EngineSounds = {
	{
	    sound = "^lfs_custom/mi28n/mi28n_rotor.wav",
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

function ENT:InitWeapons()
local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 1000
	weapon.Delay = 60 / 700
	weapon.HeatRateUp = 0.15
	weapon.HeatRateDown = 0.17
	weapon.StartAttack = function( ent )
    ent.GunSound = ent:StartLoopingSound("MI28_30MM_LOOP")
	end
	weapon.FinishAttack = function( ent )
    ent:EmitSound("MI28_30MM_STOP")
    ent:StopLoopingSound( ent.GunSound )
	end
	
	
	weapon.Attack = function( ent )
		local ID = ent:LookupAttachment( "muzzle" )
		local Muzzle = ent:GetAttachment ( ID )
		if not Muzzle then return end
		local effectdata = EffectData()
		effectdata:SetOrigin( ent:LocalToWorld( Vector(250.005,0.804,-25.79) ) )
		effectdata:SetNormal( ent:GetForward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

 	 	ent.FireLeft = not ent.FireLeft
			
		local bullet = {}
		bullet.Src 	= Muzzle.Pos --( ent:LocalToWorld( Vector(250.005,0.804,-25.79) ) )
		bullet.Dir 	= Muzzle.Ang:Forward() --ent:GetForward()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_orange"
		bullet.Force	= 10
		bullet.HullSize 	= 15
		bullet.Damage	= 18
		bullet.Velocity = 10000
		bullet.SplashDamage = 16
		bullet.SplashDamageRadius = 30
		bullet.Attacker 	= ent:GetDriver()
		bullet.Callback = function(att, tr, dmginfo)
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		util.Effect( "lvs_bullet_impact", effectdata, true, true )
	end

		ent:LVSFireBullet( bullet )

		ent:TakeAmmo( 1 )
		
		
		--weapon.OnSelect = function( ent ) ent:EmitSound("lvs_custom/ah6/select_minigun.wav") end
	    weapon.OnOverheat = function( ent ) ent:EmitSound("MI28_30MM_STOP") end
		end
		self:AddWeapon( weapon )
	
	
	-- Hydras
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/missile.png")
	weapon.Ammo = 50
	weapon.Delay = 0.3
	weapon.HeatRateUp = 0
	weapon.Attack = function( ent )

		ent.FireLeft = not ent.FireLeft

		local Driver = ent:GetDriver()
		local Target = ent:GetEyeTrace().HitPos

		local projectile = ents.Create( "lvs_missile" )
		projectile:SetPos( ent:LocalToWorld( Vector(19.36,65.89 * (self.FireLeft and 1 or -1),-13.39) ) )
		projectile:SetAngles( ent:GetAngles() )
		projectile:SetParent( ent )
		projectile:Spawn()
		projectile:Activate()
		projectile.GetTarget = function( missile ) return missile end
		projectile.GetTargetPos = function( missile )
			if missile.HasReachedTarget then
				return missile:LocalToWorld( Vector(100,0,0) )
			end

			if (missile:GetPos() - Target):Length() < 100 then
				missile.HasReachedTarget = true
			end
			return Target
		end
		projectile:SetAttacker( IsValid( Driver ) and Driver or self )
		projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
		projectile:SetSpeed( ent:GetVelocity():Length() + 4000 )
		projectile:SetDamage( 600 )
		projectile:SetRadius( 350 )
		projectile:Enable()
		projectile:EmitSound("npc/waste_scanner/grenade_fire.wav")

		ent:TakeAmmo()
	end
	
	weapon.OnSelect = function( ent )
		--ent:EmitSound("lvs_custom/ah6/select_missile.wav")
	end
	self:AddWeapon( weapon )
	
	
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/light.png")
	weapon.UseableByAI = false
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 1
	weapon.StartAttack = function( ent )
		if not ent.SetLightsEnabled then return end

		if ent:GetAI() then return end

		ent:SetLightsEnabled( not ent:GetLightsEnabled() )
		ent:EmitSound( "items/flashlight1.wav", 75, 105 )
	end
		weapon.OnSelect = function( ent )
		ent:EmitSound("lvs_custom/ah6/select_light.wav")
	end
	--self:AddWeapon( weapon )
	
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/wing_light.png")
	weapon.UseableByAI = false
	weapon.Ammo = -1
	weapon.Delay = 0
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 1
	weapon.StartAttack = function( ent )
		if not ent.SetSignalsEnabled then return end

		if ent:GetAI() then return end

		ent:SetSignalsEnabled( not ent:GetSignalsEnabled() )
		ent:EmitSound( "buttons/lightswitch2.wav", 75, 105 )
	end
		weapon.OnSelect = function( ent )
		ent:EmitSound("lvs_custom/ah6/select_signal.wav")
	end
	--self:AddWeapon( weapon )
end