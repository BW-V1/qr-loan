QRCore = exports['qr-core']:GetCoreObject()

-- local npcs = {}

Citizen.CreateThread(function()
    TriggerServerEvent("QR:SavePlyData")
end)

RegisterNetEvent('qr-loan:ClientNotify',function(Text, TextType)
    QRCore.Functions.Notify(Text, TextType, 5000)
end)

RegisterNetEvent('qr-loan:ConfirmYourLoan',function(Judge, Loan)
	local Judge, Loan = Judge, Loan
	local alert = lib.alertDialog({
		header = 'issuance of a loan',
		content = Judge.name..' He requested a new loan for you'..comma_value(Loan)..'$, Do you agree ?',
		centered = true,
		cancel = true
	})

	if alert == 'confirm' then
		TriggerServerEvent('qr-loan:ConfirmYourLoan:Accept', Judge, Loan)
	else
		print('no')
	end
end)

-- function Locations()
--     for k,v in pairs(Config.ModelSpawns) do
--         while not HasModelLoaded(v.model) do
--             RequestModel(v.model)
--             Wait(10)
--         end
--         local ped = CreatePed(v.model, v.coords.x, v.coords.y, v.coords.z - 1.0, v.heading, true, true, 0, 0)
--         while not DoesEntityExist(ped) do
--             Wait(10)
--         end

--         Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
--         SetEntityCanBeDamaged(ped, false)
--         SetEntityInvincible(ped, true)
--         FreezeEntityPosition(ped, true)
--         SetBlockingOfNonTemporaryEvents(ped, true)
--         table.insert(npcs, ped)
--         Wait(100)

--         exports['meta_target']:addInternalBoxZone(k, v.name, v.icon, v.coords, 5.0, 5.0, {
--             name=   k,
--             offset={0.0,0.0,0.0},
--             scale={1.0,1.0,1.0}
--         }, 3.5, false, {
--             {
--                 name = v.name,
--                 label = v.take,
--                 icon = v.icon,
--                 onSelect = function()
--                     CreateLoanMenu(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId())))
--                 end
--             },
--             {
--                 name = v.name,
--                 label = v.pay,
--                 icon = v.icon,
--                 onSelect = function()
--                     PayLoanMenu()
--                 end
--             }
--         }, {})
--     end
-- end
--==================== Thread's =====================--
-- Citizen.CreateThread(Locations)

-- function
function PayLoanMenu()
    QRCore.Functions.TriggerCallback('qr-loan:GetPlayerLoan', function(CurrentLoan)
        local input = lib.inputDialog(Config.text['PayLoanMenu'].input..'' ..comma_value(CurrentLoan), {
            {type = 'number', label = Config.text['PayLoanMenu'].label, min = 1 , max = Config.MaxLoan, description = Config.text['PayLoanMenu'].description, icon = 'dollar-sign'},--<i class="fa-solid fa-dollar-sign"></i>
            { type = "checkbox", label = Config.text['PayLoanMenu'].label2, checked = false }
        })

        if input and input[2] and input[2] == true then

            local Loan
            if input[1] then
                Loan = tonumber(input[1])

                TriggerServerEvent('qr-loan:PayOffYourLoan', Loan)
            else
                QRCore.Functions.Notify(Config.Notify['error'].error1, 'error', 5000)
            end
        else
            QRCore.Functions.Notify(Config.Notify['error'].error2, 'info', 5000)
        end
    end)
end

-- CreateLoanMenu Function
-- This function creates a loan menu for the given player ID (PlyId).

function CreateLoanMenu(PlyId)
    -- Trigger a callback to check if the player already has a loan
    QRCore.Functions.TriggerCallback('qr-loan:DoesPlayerHaveLoan', function(DoesPlayerHaveLoan)
        -- Handle different cases based on whether the player has a loan or not
        if DoesPlayerHaveLoan == true then
            QRCore.Functions.Notify(Config.Notify['error'].error3, 'error', 5000)
            
        elseif DoesPlayerHaveLoan == false then
            -- Create an input dialog for the loan
            local input = lib.inputDialog(Config.text['CreateLoanMenu'].input2, {
                { type = 'select', label = Config.text['CreateLoanMenu'].labels, options = Config.LoansMenu },
                { type = 'checkbox', label = Config.text['CreateLoanMenu'].labels2, checked = false }
            })
            
            -- Check if the input is valid and the checkbox is checked
            if input and input[2] and input[2] == true then
                local Loan
                
                if input[1] then
                    Loan = tonumber(input[1])
                    TriggerServerEvent('qr-loan:CreateNewLoan', PlyId, Loan)
                    QRCore.Functions.Notify(Config.Notify['success'].success1, 'success', 5000)
                    
                else
                    QRCore.Functions.Notify(Config.Notify['error'].error1, 'error', 5000)
                end
                
            else
                QRCore.Functions.Notify(Config.Notify['error'].error2, 'inform', 5000)
            end
            
        elseif DoesPlayerHaveLoan == 'missingplayer' then
            QRCore.Functions.Notify(Config.Notify['error'].error4, 'error', 5000)
        end
    end, PlyId)
end


-- AddEventHandler('onResourceStop', function(resource)
--     if (resource == GetCurrentResourceName()) then
--         for k,v in pairs(npcs) do
--             DeletePed(v)
--             SetEntityAsNoLongerNeeded(v)
--         end
--         for k,v in pairs(Config.ModelSpawns) do
--             exports['meta_target']:remove(k)
--         end
--     end
-- end)