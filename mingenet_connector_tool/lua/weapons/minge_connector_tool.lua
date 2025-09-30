SWEP.Category = "1999"
SWEP.PrintName = "Mingenet Connection Tool"

SWEP.ViewModelFOV		= 62
SWEP.ViewModel			= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"

SWEP.Spawnable = true 
SWEP.AdminOnly = true

SWEP.UseHands = true
SWEP.DrawAmmo = false

local Sound = "ui/buttonclick.wav"

SWEP.Primary.Ammo		= ""
SWEP.Secondary.Ammo		= ""

if CLIENT then
    local isOpen = false
    local f = nil
	
    local function createPanel(ply)
        if isOpen then return end
        f = vgui.Create("DFrame")
        f:SetTitle("Mingenet Connection Tool")
        f:SetSize(300, 100)
        f:Center()
        f:MakePopup()
        isOpen = true
		
        local b = vgui.Create("DButton", f)
        b:SetSize(150, 50)
        b:SetPos(75, 40)
        b:SetText("Get mingebag count")
        b.DoClick = function()
		    ply:EmitSound("common/bugreporter_succeeded.wav", 75, 100, 1)
			f:Close()
            local count = 0
            for _, ent in pairs(ents.GetAll()) do
                if ent:GetClass() == "gm13_mingebag" then
                    count = count + 1
                end
            end
            ply:PrintMessage(HUD_PRINTTALK, "Mingebag(s) count: " .. count)
        end
        f.OnClose = function()
            isOpen = false
        end
    end
    hook.Add("KeyPress", "UseKey", function(ply, key)
        if key == IN_USE then
            local aw = ply:GetActiveWeapon()
            if IsValid(aw) and aw:GetClass() == "minge_connector_tool" then
                if not isOpen then
                    createPanel(ply)
                end
            end
        end
    end)
end

function SWEP:Deploy()
    self.Owner:PrintMessage( HUD_PRINTTALK, "NOTE: Make sure you have devmode_gm13_toggle toggled on so that you can see if it works." )
    self.Weapon:EmitSound("buttons/button14.wav", 75, 100, 1, CHAN_VOICE_BASE)
end

function SWEP:Initialize()
    self:SetWeaponHoldType("revolver")
end

function SWEP:PrimaryAttack()
    if not GM13 then return end
    self:ShootEffects()
	self:EmitSound(Sound, 75, 100, 1, CHAN_VOICE_BASE)
	self:SetNextPrimaryFire( CurTime() + 1.25 )
	if GM13 and GM13.Lobby and GM13.Lobby.SelectBestServer then
        GM13.Lobby:SelectBestServer()
		self.Owner:PrintMessage( HUD_PRINTTALK, "Searching for the best servers, please wait." )
		self.Owner:EmitSound("friends/message.wav", 75, 100, 1, CHAN_VOICE_BASE)
    end
end

function SWEP:SecondaryAttack()
    if not GM13 then return end
    self:ShootEffects()
	self:EmitSound(Sound, 75, 100, 1, CHAN_VOICE_BASE)
	self:SetNextSecondaryFire( CurTime() + 1.25 )
    if GM13 and GM13.Lobby and GM13.Lobby.ForceDisconnect then
	    GM13.Lobby:ForceDisconnect()
		self.Owner:PrintMessage( HUD_PRINTTALK, "Force stopped." )
		self.Owner:EmitSound("friends/friend_join.wav", 75, 100, 1, CHAN_VOICE_BASE)
	end
end

if (CLIENT) then
    local matScreen = Material("models/weapons/v_toolgun/screen")
    local txBackground = surface.GetTextureID("models/weapons/v_toolgun/screen_bg")
    local TEX_SIZE = 256

    -- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
    local RTTexture = GetRenderTarget("GModToolgunScreen", TEX_SIZE, TEX_SIZE)

    local FONTS = {
        "BudgetLabel",
        "CloseCaption_Italic",
        "DermaLarge",
        "TargetID",
        "HDRDemoText",
        "CenterPrintText",
        "Helvetica"
    }

    local basefont = "UTRBAG_"
    local currentfontindex = 1
    local currentFont = basefont .. "1"

    for i, v in pairs(FONTS) do
        surface.CreateFont(
            basefont .. i,
            {
                font = v,
                size = 60,
                weight = 900
            }
        )

        surface.CreateFont(
            basefont .. i .. "kill",
            {
                font = v,
                size = ScreenScale(7),
                weight = 900,
                outline = math.random() > 0
            }
        )
    end

    local function DrawScrollingText(text, y, texwide)
        local w, h = surface.GetTextSize(text)
        w = w + 64

        y = y - h / 2 -- Center text to y position

        local x = RealTime() * 250 % w * -1

        while (x < texwide) do
            surface.SetTextColor(0, 0, 0, 255)
            surface.SetTextPos(x + 3, y + 3)
            surface.DrawText(text)

            surface.SetTextColor(255, 255, 255, 255)
            surface.SetTextPos(x, y)
            surface.DrawText(text)

            x = x + w
        end
    end
    function SWEP:RenderScreen()
        -- Set the material of the screen to our render target
        matScreen:SetTexture("$basetexture", RTTexture)

        -- Set up our view for drawing to the texture
        render.PushRenderTarget(RTTexture)
        cam.Start2D()
        -- Background
        surface.SetDrawColor(255, 0, 0, 255)
        surface.SetTexture(txBackground)
        surface.DrawTexturedRect(0, 0, TEX_SIZE, TEX_SIZE)
        surface.SetFont(currentFont)
        --print(currentFont)
        DrawScrollingText("Mingenet Connection Tool", 104, TEX_SIZE)

        cam.End2D()
        render.PopRenderTarget()
    end
end

