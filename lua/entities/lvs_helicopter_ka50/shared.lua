
ENT.Base = "lvs_base_helicopter"

ENT.PrintName = "Ka 50 \"Black Shark\""
ENT.Category = "[LVS] - Helicopters"

ENT.VehicleCategory = "Helicopters"
ENT.VehicleSubCategory = "Heli Wars"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/heli/rus/ka50/ka50.mdl"
--ENT.MDL_DESTROYED = 	"models/lfs_merydian/helicopters/ah1z/gibs/viper_1.mdl"

ENT.AITEAM = 1

ENT.MaxHealth = 800

ENT.MaxVelocity = 2450

ENT.ThrustUp = 1.3
ENT.ThrustDown = 0.9
ENT.ThrustRate = 0.9

ENT.ThrottleRateUp = 0.15
ENT.ThrottleRateDown = 0.1

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1
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
	self:AddDT( "Float", "LandingGear" )
	
	if SERVER then
		self:SetLandingGear( 1 )
	end
	
end

function ENT:InitWeapons()
local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 1100
	weapon.Delay = 60 / 600
	weapon.HeatRateUp = 0.2
	weapon.HeatRateDown = 0.25
	weapon.StartAttack = function( ent )
    ent.GunSound = ent:StartLoopingSound("MI28_30MM_LOOP")
	end
	weapon.FinishAttack = function( ent )
    ent:EmitSound("MI28_30MM_STOP")
    ent:StopLoopingSound( ent.GunSound )
	end
	
	
	weapon.Attack = function( ent )
	
	
			local effectdata = EffectData()
			effectdata:SetOrigin( ent:LocalToWorld( Vector(127.005,-32.804,38) ) )
			effectdata:SetNormal( ent:GetForward() )
			effectdata:SetEntity( ent )
			util.Effect( "lvs_muzzle", effectdata )
			
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
		bullet.Src 	= ( ent:LocalToWorld( Vector(127.005,-32.804,38) ) )
		bullet.Dir 	= (trace.HitPos - bullet.Src):GetNormalized() --ent:GetForward()
		bullet.Spread 	= Vector( 0,  0.01, 0.01 )
		bullet.TracerName = "lvs_tracer_white"
		bullet.Force	= 15000
		bullet.HullSize 	= 15
		bullet.Damage	= 25
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
		
		
		--weapon.OnSelect = function( ent ) ent:EmitSound("lvs_custom/ah6/select_minigun.wav") end
	    weapon.OnOverheat = function( ent ) ent:EmitSound("MI28_30MM_STOP") end
		end
		self:AddWeapon( weapon )
		
	
	-- Hydras
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
	

	-- hellfire
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/bomb.png")
	weapon.Ammo = 20
	weapon.Delay = 0.5
	weapon.HeatRateUp = 0
	weapon.Attack = function( ent )

		ent.FireLeft = not ent.FireLeft

		local Driver = ent:GetDriver()
		local Target = ent:GetEyeTrace().HitPos

		local projectile = ents.Create( "lvs_missile" )
		projectile:SetPos( ent:LocalToWorld( Vector(19.36,105.89 * (self.FireLeft and 1 or -1),45.39) ) )
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
		projectile:SetSpeed( ent:GetVelocity():Length() + 2000 )
		projectile:SetDamage( 600 )
		projectile:SetRadius( 550 )
		projectile:Enable()
		projectile:EmitSound("weapons/stinger_fire1.wav")

		ent:TakeAmmo()
	end
	
	weapon.OnSelect = function( ent )
		ent:EmitSound("physics/metal/weapon_impact_soft3.wav")
	end
	self:AddWeapon( weapon )
	
local weapon = {}
	weapon.Icon = Material("lvs/weapons/bomb.png")
	weapon.UseableByAI = false
	weapon.Ammo = 2
	weapon.Delay = 0.25
	weapon.HeatRateUp = -0.4
	weapon.HeatRateDown = 0.4
	weapon.StartAttack = function( ent )
		local Driver = ent:GetDriver()

		local projectile = ents.Create( "lvs_bomb" )
		projectile:SetPos( ent:LocalToWorld( Vector(-50,0,-25) ) )
		projectile:SetAngles( ent:GetAngles() )
		projectile:SetParent( ent )
		projectile:Spawn()
		projectile:Activate()
		projectile:SetAttacker( IsValid( Driver ) and Driver or ent )
		projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )
		projectile:SetSpeed( ent:GetVelocity() )
		projectile:SetDamage( 150 )
		projectile:SetRadius( 250 )

		self._ProjectileEntity = projectile
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent._ProjectileEntity ) then return end

		ent._ProjectileEntity:Enable()
		--ent._ProjectileEntity:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav")

		ent:TakeAmmo()

		ent:SetHeat( ent:GetHeat() + 0.2 )

		if ent:GetHeat() >= 1 then
			ent:SetOverheated( true )
		end
	end
	self:AddWeapon( weapon )
	
end

function ENT:StartCommand( ply, cmd )
	if self:GetDriver() ~= ply then return end

	if SERVER then
		local KeyJump = ply:lvsKeyDown( "VSPEC" )

		if self._lvsOldKeyJump ~= KeyJump then
			self._lvsOldKeyJump = KeyJump

			if KeyJump then
				self:ToggleVehicleSpecific()
				self:ToggleLandingGear()
				self:PhysWake()
			end
		end
	end

	if not ply:lvsMouseAim() then
		self:PlayerDirectInput( ply, cmd )
	end
end