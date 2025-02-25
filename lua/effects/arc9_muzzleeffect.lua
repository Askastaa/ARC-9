EFFECT.Weapon = nil

function EFFECT:Init(data)
    local wpn = data:GetEntity()

    self.Weapon = wpn

    if !IsValid(wpn) then self:Remove() return end

    if !GetConVar("arc9_muzzle_others"):GetBool() and LocalPlayer() != wpn:GetOwner() then
        self:Remove()
        return
    end

    local muzzle = wpn:GetProcessedValue("MuzzleParticle")

    local att = data:GetAttachment() or 1

    local vm = LocalPlayer():GetViewModel()

    local wm = false

    if (LocalPlayer():ShouldDrawLocalPlayer() or wpn.Owner != LocalPlayer()) then
        wm = true
        att = 1
    end

    local parent = wpn

    if !wm then
        parent = vm
    else
        parent = (wpn.WModel or {})[1] or wpn
    end

    local muz = wpn:GetMuzzleDevice(wm, data:GetSurfaceProp())

    if !IsValid(muz) then
        muz = wpn
    end

    if !IsValid(muz) then
        self:Remove()
        return
    end

    local pa = muz:GetAttachment(att)
    local pos = pa and pa.Pos or muz:GetPos()

    -- if !IsValid(parent) then return end

    -- if muzzle then
    --     ParticleEffectAttach(muzzle, PATTACH_POINT_FOLLOW, muz or parent, att)
    -- end

    if muzzle then
        if !istable(muzzle) then
            muzzle = {muzzle}
        end

        for _, muzzleeffect in ipairs(muzzle) do
            local pcf = CreateParticleSystem(muz or parent, muzzleeffect, PATTACH_POINT_FOLLOW, att)

            if IsValid(pcf) then
                pcf:StartEmission()

                if (muz or parent) != vm and !wm then
                    pcf:SetShouldDraw(false)
                    table.insert(wpn.PCFs, pcf)
                end
            end
        end
    end

    if !wpn:GetProcessedValue("Silencer") and !wpn:GetProcessedValue("NoFlash") and GetConVar("arc9_muzzle_light"):GetBool() then
        local light = DynamicLight(self:EntIndex())
        local clr = Color(244, 209, 66)
        if (light) then
            light.Pos = pos
            light.r = clr.r
            light.g = clr.g
            light.b = clr.b
            light.Brightness = 2
            light.Decay = 2500
            light.Size = wpn:GetOwner() == LocalPlayer() and 256 or 128
            light.DieTime = CurTime() + 0.1
        end
    end

    if ARC9.Dev(2) then debugoverlay.Sphere(pos, 2, 1, Color(255, 255, 255, 1)) end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
    return false
end