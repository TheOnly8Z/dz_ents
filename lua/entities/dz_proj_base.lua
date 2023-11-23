AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "DZ Base Plantable Projectile"
ENT.Author = ""
ENT.Information = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.WeaponClass = ""
ENT.Model = "models/props_junk/PopCan01a.mdl"
ENT.LockYaw = false
ENT.AdjustPitch = false
ENT.AdjustOffset = false
ENT.MinS = Vector(-2, -5, 0)
ENT.MaxS = Vector(2, 5, 8)
ENT.Bury = 0

ENT.BurySurfaces = {
    [MAT_DIRT] = true,
    [MAT_SAND] = true,
    [MAT_GRASS] = true,
    [MAT_FLESH] = true,
    [MAT_BLOODYFLESH] = true,
    [MAT_SNOW] = true,
    [MAT_SLOSH] = true,
}

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "ArmTime")
    self:NetworkVar("Angle", 0, "Adjustment")
end

function ENT:OnInitialize()
end

function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:PhysicsInitBox(self.MinS, self.MaxS)
        self:DrawShadow(true)
        self:SetArmTime(-1)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()

        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(5)
            phys:SetBuoyancyRatio(0.1)
        end

        self:SetHealth(10)
        self:SetMaxHealth(10)

        self.SpawnAngle = self:GetAngles().y

        self.Attacker = self:GetOwner()
    end
    self.SpawnTime = CurTime()

    self:OnInitialize()
end

function ENT:GetArmed()
    return self:GetArmTime() > 0 and CurTime() > self:GetArmTime() + self.ArmDelay
end

if SERVER then
    function ENT:OnPlant()
    end

    function ENT:Plant(ent, pos, normal, v)
        if self:GetArmTime() > 0 then return end
        local livingthing = ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()
        -- if IsValid(ent) then return end -- and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot())
        -- The AdjustOffset nudge works poorly when the entity is not already aligned with the surface
        local adjustoffset = not livingthing and self.AdjustOffset and self:GetUp():Dot(normal) > 0.5

        -- Use the normal to place our center on the surface if possible
        if livingthing then
            normal = v * -1
            debugoverlay.Line(pos, pos + v * 8, 5, Color(255, 0, 255), true)
        elseif v and not adjustoffset then
            local wsc = self:WorldSpaceCenter()
            local tr = util.TraceLine({
                start = wsc,
                endpos = wsc - normal * 24,
                filter = {self, self:GetOwner()},
                mask = MASK_SOLID,
                collisiongroup = self:GetCollisionGroup(),
            })
            debugoverlay.Line(tr.StartPos, tr.HitPos, 5, Color(255, 0, 0), true)
            debugoverlay.Cross(tr.HitPos, 4, 5, Color(255, 0, 0), true)
            debugoverlay.Cross(pos, 4, 5, Color(255, 0, 255), true)
            debugoverlay.Line(tr.HitPos, tr.HitPos + tr.HitNormal * 8, 5, Color(255, 0, 255), true)
            -- If we find a spot for the center, treat that as the location; otherwise don't adjust (it will visually snap but at least the pos/ang will be correct)
            if tr.Hit then
                pos = tr.HitPos
                normal = tr.HitNormal
                ent = tr.Entity
            end
        end

        self:SetOwner(NULL)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

        local a = Angle(0, self.LockYaw and self.SpawnAngle or self:GetAngles().y, 0)
        local f = a:Forward()

        local na = normal:Angle()
        na:RotateAroundAxis(na:Right(), -90)

        local angle = Angle(na)
        local dir = angle:Forward()
        dir.z = 0
        dir:Normalize()

        local turn = angle:Forward():Cross(dir):GetNormalized()
        local theta = math.deg(math.acos(angle:Forward():Dot(dir)))

        angle:RotateAroundAxis(turn, theta)
        angle:RotateAroundAxis(dir:Cross(f):GetNormalized(), math.deg(math.acos(dir:Dot(f))))
        angle:RotateAroundAxis(turn, -theta)

        if self.AdjustPitch then
            self:SetAdjustment(Angle(-math.Clamp(theta * 0.5, 3, 15), 0, 0))
        end

        if adjustoffset then
            local offset = self:WorldToLocal(pos)
            pos = pos + angle:Forward() * -offset.x + angle:Right() * offset.y
        end

        if self.Bury > 0 then
            local tr_mat = util.TraceLine({
                start = pos + normal,
                endpos = pos - normal,
                filter = {self},
            })
            if self.BurySurfaces[tr_mat.MatType] and normal:Dot(Vector(0, 0, 1)) >= 0.5 then
                pos = pos - normal * self.Bury
                self:DrawShadow(false)
            end
        end

        if ent:IsWorld() or (IsValid(ent) and ent:GetSolid() == SOLID_BSP) then
            self:SetMoveType(MOVETYPE_NONE)
            self:SetPos(pos)
        else
            self:SetPos(pos)
            self:SetParent(ent)
        end

        self:SetAngles(angle)
        self:SetArmTime(CurTime())

        self:OnPlant()
    end

    function ENT:PhysicsCollide(data, physobj)
        self:Plant(data.HitEntity, data.HitPos, -data.HitNormal, data.OurOldVelocity:GetNormalized())
    end

    function ENT:Detonate()
        self:Remove()
    end

    function ENT:OnTakeDamage(dmg)
        self:SetHealth(self:Health() - dmg:GetDamage())
        if not self.BOOM and self:Health() <= 0 then
            self.BOOM = true

            -- Re-attribute credit to the person who destroyed the mine, unless it is the world
            self.Attacker = IsValid(dmg:GetAttacker()) and dmg:GetAttacker() or self.Attacker

            self:Detonate()
        end
        return dmg:GetDamage()
    end

    function ENT:Use(act, call, calltype, integer)
        if not self.BOOM and IsValid(act) and act:IsPlayer() and self:GetArmed() and act:EyePos():DistToSqr(self:GetPos()) <= 100 * 100 then
            if self.WeaponClass then
                act:GiveAmmo(1, weapons.Get(self.WeaponClass).Primary.Ammo, true)
                act:Give(self.WeaponClass, true)
            end

            self:EmitSound("DZ_Ents.BumpMine.Pickup")
            self:Remove()
        end
    end
else
    function ENT:DrawTranslucent()
        self:Draw()
    end

    function ENT:Draw()
        self:DrawModel()
    end
end