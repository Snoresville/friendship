LinkLuaModifier("friendship_modifier", "abilities/friendship", LUA_MODIFIER_MOTION_NONE)
friendship = class({})
friendship_modifier = class({})

function friendship:GetIntrinsicModifierName()
    return "friendship_modifier"
end

function friendship:attack(target)
    ProjectileManager:CreateTrackingProjectile({
        Target = target,
        iMoveSpeed = self:GetCaster():IsRangedAttacker() and self:GetCaster():GetProjectileSpeed() or 1200,
        flExpireTime = GameRules:GetDOTATime(false, true) + 1000,
        bDodgeable = true,
        bIsAttack = false,
        bReplaceExisting = false,
        bIgnoreObstructions = false,
        bSuppressTargetCheck = false,
        bIsVisibleToEnemies = true,
        EffectName = "particles/units/heroes/hero_wisp/wisp_base_attack.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        bProvidesVision = false,
        vSourceLoc = self:GetCaster():GetAbsOrigin(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    })
    self:GetCaster():EmitSound("Hero_Wisp.Attack")
end

function friendship:OnProjectileHit(target, location)
    if not target or not target:IsAlive() then return end

    self:GetCaster().is_attacking = true
    self:GetCaster():PerformAttack(target, true, true, true, true, false, false, true)
    self:GetCaster().is_attacking = false
end


function friendship_modifier:IsHidden()
    return true
end

function friendship_modifier:DeclareFunctions()
    if IsClient() then return {} end
    return {
        MODIFIER_EVENT_ON_ATTACK
    }
end

function friendship_modifier:OnAttack(kv)
    if not self:GetCaster():IsAlive() then return end

    local ability = kv.attacker:FindAbilityByName("friendship")
    if kv.attacker:GetTeamNumber() == self:GetCaster():GetTeamNumber() and ability and kv.attacker.is_attacking ~= true and kv.attacker ~= self:GetCaster() then
        self:GetAbility():attack(kv.target)
    end
end