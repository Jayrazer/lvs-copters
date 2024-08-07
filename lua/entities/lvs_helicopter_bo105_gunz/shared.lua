
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "Bo 105 (Gunpods)"
ENT.Category = "[LVS] - Helicopters"

ENT.VehicleCategory = "Helicopters"
ENT.VehicleSubCategory = "Heli Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/lfs_merydian/wt_helicopters/bo105_1a1.mdl"
--ENT.MDL_DESTROYED = 	"models/lfs_merydian/helicopters/ah1z/gibs/viper_1.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 300

ENT.MaxVelocity = 2700

ENT.ThrustUp = 1.4
ENT.ThrustDown = 0.8
ENT.ThrustRate = 0.9

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1.5
ENT.TurnRateYaw = 2
ENT.TurnRateRoll = 1.5

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
	    sound = "lvs_copters/engine/rotor2.wav",
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
	    sound = "lvs_copters/engine/rpm3.wav",
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
	weapon.Icon = Material("lvs/weapons/dual_mg.png")
	weapon.Ammo = 1000
	weapon.Delay = 60 / 1200
	weapon.HeatRateUp = 0.2
	weapon.HeatRateDown = 0.25
	weapon.StartAttack = function( ent )
    ent.GunSound = ent:StartLoopingSound("GUNPODS_LOOP")
	end
	weapon.FinishAttack = function( ent )
    ent:EmitSound("GUNPODS_STOP")
    ent:StopLoopingSound( ent.GunSound )
	end
	
	
	weapon.Attack = function( ent )
			local effectdata = EffectData()
			effectdata:SetOrigin( ent:LocalToWorld( Vector(37.005,61.804 * (self.FireLeft and 1 or -1),-23.79) ) )
			effectdata:SetNormal( ent:GetForward() )
			effectdata:SetEntity( ent )
			util.Effect( "lvs_muzzle", effectdata )

 	 	 	ent.FireLeft = not ent.FireLeft
			
		local pod = ent:GetDriverSeat()
		if not IsValid( pod ) then return end
		local startpos = pod:LocalToWorld( pod:OBBCenter() )
		local trace = util.TraceHull( {
			start = startpos,
			endpos = (startpos + ent:GetForward() * 50000),
			mins = Vector( -10, -10, -10 ),
			maxs = Vector( 10, 10, 10 ),
			filter = ent:GetCrosshairFilterEnts()
		} )
			
		local bullet = {}
		bullet.Src 	= ( ent:LocalToWorld( Vector(37.005,61.804 * (self.FireLeft and 1 or -1),-23.79) ) )
		bullet.Dir 	= (trace.HitPos - bullet.Src):GetNormalized() --ent:GetForward()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_orange"
		bullet.Force	= 6000
		bullet.HullSize 	= 15
		bullet.Damage	= 10
		bullet.Velocity = 8000
		bullet.SplashDamage = 10
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
	    weapon.OnOverheat = function( ent ) ent:EmitSound("AH6_MGLAST_OVERHEAT") end
		end
		self:AddWeapon( weapon )
end