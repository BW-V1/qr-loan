--qr-loan

--[[
    `loan` INT(11) NULL DEFAULT '0',
    `loanjudge` VARCHAR(60) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
]]

local QRCore = exports['qr-core']:GetCoreObject()


QRCore.Functions.CreateCallback('qr-loan:DoesPlayerHaveLoan', function(source, cb, target) 
    local xTarget = QRCore.Functions.GetPlayer(target)
    local license = QRCore.Functions.GetIdentifier(target, "license")

    if xTarget then
        local Loan = MySQL.scalar.await('SELECT loan FROM loanbank WHERE license = ? AND steam = ? AND discord = ?', {
            license,
            GetPlayerIdentifiers(target)[1],
            QRCore.Functions.GetIdentifier(target, 'discord'),
        })
        if tonumber(Loan) > 0 then
            cb(true)
        elseif tonumber(Loan) == 0 then
            cb(false)
        end
    else
        cb('missingplayer')
    end
end)

QRCore.Functions.CreateCallback('qr-loan:GetPlayerLoan', function(source, cb) 
    local xPlayer = QRCore.Functions.GetPlayer(source)
    local license = QRCore.Functions.GetIdentifier(source, "license")
    cb(MySQL.scalar.await('SELECT loan FROM loanbank WHERE license = ? AND steam = ? AND discord = ?', {
        license,
        GetPlayerIdentifiers(source)[1],
        QRCore.Functions.GetIdentifier(source, 'discord'),
    }))
end)

RegisterServerEvent('qr-loan:PayOffYourLoan')
AddEventHandler('qr-loan:PayOffYourLoan',function(amount)
    local source = source
    local amount = amount
    local xPlayer = QRCore.Functions.GetPlayer(source)
    local license = QRCore.Functions.GetIdentifier(source, "license")
    local Loan = MySQL.scalar.await('SELECT loan FROM loanbank WHERE license = ? AND steam = ? AND discord = ?', {
        license,
        GetPlayerIdentifiers(source)[1],
        QRCore.Functions.GetIdentifier(source, 'discord'),
    })
    if Loan > 0 then
        if amount > Loan then 
            amount = Loan 
        end

        local NewLoan = (Loan - amount)

        if xPlayer.Functions.GetMoney('cash') >= amount then
            MySQL.update.await('UPDATE loanbank SET loan = ? WHERE license = ? AND steam = ? AND discord = ?', {
                NewLoan,
                license,
                GetPlayerIdentifiers(source)[1],
                QRCore.Functions.GetIdentifier(source, 'discord'),
            })
            xPlayer.Functions.RemoveMoney('cash', tonumber(amount))
            
            LoanDiscordLog('القروض', xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname..' قام بإيداع '..comma_value(amount)..'$ كاش لسداد القرض ( القرض : '..comma_value(Loan)..'$)', 'green')

            TriggerClientEvent('qr-loan:ClientNotify', source, 'لقد اودعت '..comma_value(amount)..'$ لسداد قرضك', 'success')
        elseif xPlayer.Functions.GetMoney('bank') >= amount then
            MySQL.update.await('UPDATE loanbank SET loan = ? WHERE license = ? AND steam = ? AND discord = ?', {
                NewLoan,
                license,
                GetPlayerIdentifiers(source)[1],
                QRCore.Functions.GetIdentifier(source, 'discord'),
            })
            xPlayer.Functions.RemoveMoney('bank', tonumber(amount))

            LoanDiscordLog('القروض', xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname..' قام بإيداع '..comma_value(amount)..'$ بنك لسداد القرض ( القرض : '..comma_value(Loan)..'$)', 'green')

            TriggerClientEvent('qr-loan:ClientNotify', source, 'لقد اودعت '..comma_value(amount)..'$ لسداد قرضك', 'success')
        else
            TriggerClientEvent('qr-loan:ClientNotify', source, 'لا يوجد لديك هذا المبلغ', 'error')
        end
    else
        TriggerClientEvent('qr-loan:ClientNotify', source, 'لا يوجد لديك اي قرض', 'inform')
    end
end)

RegisterServerEvent('qr-loan:CreateNewLoan')
AddEventHandler('qr-loan:CreateNewLoan',function(target, amount)
    local xPlayer = QRCore.Functions.GetPlayer(source)
    local xTarget = QRCore.Functions.GetPlayer(target)

    if xPlayer and xTarget then
        TriggerClientEvent('qr-loan:ConfirmYourLoan', xTarget.PlayerData.source, {name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname, source = xPlayer.PlayerData.source}, amount)
        LoanDiscordLog('القروض', ' عملية إنشاء قرض جديد بقيمة '..comma_value(amount)..'$ من قبل '..xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname, 'blue')
    end
end)

RegisterServerEvent('qr-loan:ConfirmYourLoan:Accept')
AddEventHandler('qr-loan:ConfirmYourLoan:Accept',function(Judge, amount)
    local xPlayer = QRCore.Functions.GetPlayer(source)
    local xTarget = QRCore.Functions.GetPlayer(Judge.source)
    local xlicense = QRCore.Functions.GetIdentifier(source, "license")
    local license = QRCore.Functions.GetIdentifier(Judge.source, "license")

    local Loan = MySQL.scalar.await('SELECT loan FROM loanbank WHERE license = ? AND steam = ? AND discord = ?', {
        license,
        GetPlayerIdentifiers(Judge.source)[1],
        QRCore.Functions.GetIdentifier(Judge.source, 'discord'),
    })

    if xTarget and xPlayer then
        if tonumber(Loan) == 0 then
                MySQL.update.await('UPDATE loanbank SET loan = ? WHERE license = ? AND steam = ? AND discord = ?', {
                    tonumber(amount*Config.LoanProfit),
                    license,
                    GetPlayerIdentifiers(Judge.source)[1],
                    QRCore.Functions.GetIdentifier(Judge.source, 'discord'),
                })
                MySQL.update.await('UPDATE loanbank SET loanjudge = ? WHERE license = ? AND steam = ? AND discord = ?', {
                    license,
                    GetPlayerIdentifiers(Judge.source)[1],
                    QRCore.Functions.GetIdentifier(Judge.source, 'discord'),
                })
                MySQL.update.await('UPDATE loanbank SET loandate = ? WHERE license = ? AND steam = ? AND discord = ?', {
                    os.time(),
                    license,
                    GetPlayerIdentifiers(Judge.source)[1],
                    QRCore.Functions.GetIdentifier(Judge.source, 'discord'),
                })

                xPlayer.Functions.AddMoney('bank', tonumber(amount))
                TriggerClientEvent('qr-loan:ClientNotify', xPlayer.PlayerData.source, ' تم إصدار القرض بنجاح - ('..comma_value(tonumber(amount))..'$)', 'success')
                local itemdescription = 'المحكمه   \n'
                itemdescription = itemdescription .. 'تم إصدار قرض بتاريخ : '..GetDate()..'   \n'
                itemdescription = itemdescription .. 'المواطن : '..xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname..'   \n'
                itemdescription = itemdescription .. '$مبلغ القرض : '..comma_value(tonumber(amount))..'    \n'

                local iteminfo = {
                    label = 'سند إصدار قرض',
                    line2 = GetDate(),
                    line3 = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname,
                    line4 = comma_value(tonumber(amount)),
                }
                xPlayer.Functions.AddItem('loanpaper', 1, false, iteminfo)
                
                LoanDiscordLog('القروض', xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname..' قام بالموافقه على إخراج القرض المصدر من القاضي '..xTarget.PlayerData.charinfo.firstname..' '..xTarget.PlayerData.charinfo.lastname..' بقيمة '..comma_value(amount)..'$', 'orange')
        
            else
                print('1')
            TriggerClientEvent('qr-loan:ClientNotify', xPlayer.PlayerData.source, ' لديك قرض سابق', 'error')
        end
    end
end)

RegisterServerEvent('qr-loan:ConfirmYourLoan:Decline')
AddEventHandler('qr-loan:ConfirmYourLoan:Decline',function(Judge)
    local xPlayer = QRCore.Functions.GetPlayer(source)
    local xTarget = QRCore.Functions.GetPlayer(Judge.source)
    if xTarget then
        LoanDiscordLog('القروض', xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname..' رفض إخراج القرض المصدر من قبل '..xTarget.PlayerData.charinfo.firstname..' '..xTarget.PlayerData.charinfo.lastname, 'green')
        TriggerClientEvent('qr-loan:ClientNotify', xTarget.PlayerData.source, xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname..' قام برفض إصدار القرض', 'error')
    end
end)

RegisterNetEvent('QR:SavePlyData', function()
    local src = source
    local license = QRCore.Functions.GetIdentifier(src, "license")
    local result = MySQL.query.await('SELECT * FROM loanbank WHERE license = ?', {license})

    if result[1] then 
        MySQL.update('UPDATE loanbank SET steam = ? WHERE license = ?', {GetPlayerIdentifiers(src)[1], license})
        MySQL.update('UPDATE loanbank SET discord = ? WHERE license = ?', {QRCore.Functions.GetIdentifier(src, 'discord'), license})
    else 
        MySQL.insert('INSERT INTO loanbank (license, steam, discord) VALUES (?, ?, ?)', {
            QRCore.Functions.GetIdentifier(src, 'license'),
            GetPlayerIdentifiers(src)[1],
            QRCore.Functions.GetIdentifier(src, 'discord'),
        })
    end
    print('\x1b[32m[' .. GetCurrentResourceName() .. ']\x1b[0m ' .. GetPlayerName(src) .. " Data updated!")
end)

function GetDate()
    local date = os.date('*t')
    if date.day < 10 then date.day = '0' .. tostring(date.day) end
    if date.month < 10 then date.month = '0' .. tostring(date.month) end
    if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
    if date.min < 10 then date.min = '0' .. tostring(date.min) end
    if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
    local FilteredDate = date.day .. '/' .. date.month .. '/' .. date.year .. ' - ' .. date.hour .. ':' .. date.min
    return FilteredDate
end

function GiveJudgeHisCutt(judgeid, amount)
    if judgeid then
        local judgeid, amount = judgeid, amount
        local Judge = QRCore.Functions.GetPlayer(judgeid)
        local JudgeCutt = math.floor( (amount*0.15) )

        if Judge then 
            Judge.Functions.AddMoney('bank', JudgeCutt)
        else
            local PlayerBank = {}
            local PlayerBank = json.decode(MySQL.Sync.fetchScalar('SELECT money FROM loanbank WHERE license = ?', {judgeid}))

            if PlayerBank['bank'] then
                PlayerBank['bank'] = PlayerBank['bank'] + JudgeCutt
            end

            MySQL.Async.execute("UPDATE loanbank SET money = @money WHERE license = @license",{
                ["@license"] = judgeid,
                ["@money"] = json.encode(PlayerBank)
            })
        end
    end
end

--LoanDiscordLog('name','message', 'green')
function LoanDiscordLog(name, message, color)
    local DiscordWebHook = Config.WEEBHOOK
    if color == nil then color = 8421504
    elseif color == 'green' then color = 56108
    elseif color == 'grey' then color = 8421504
    elseif color == 'red' then color = 16711680
    elseif color == 'orange' then color = 16744192
    elseif color == 'blue' then color = 2061822
    elseif color == 'purple' then color = 11750815 end
    local date = os.date('*t')
    if date.day < 10 then date.day = '0' .. tostring(date.day) end
    if date.month < 10 then date.month = '0' .. tostring(date.month) end
    if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
    if date.min < 10 then date.min = '0' .. tostring(date.min) end
    if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
    local embeds = {
        {
            ['title']=message.. ' `' .. date.day .. '.' .. date.month .. '.' .. date.year .. ' - ' .. date.hour .. ':' .. date.min .. ':' .. date.sec .. '`',
            ['type']='rich',
            ['color'] = color,
            ['footer']=  {
            ['text']= 'ArabTOP to Discord',
            },
        }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

-- RegisterCommand('commandname',function(source, args, rawCommand)
--     local PassedPayTime, AmountLeft = exports['qr-loan']:DoesPlayerHaveLoan(source)
--     if PassedPayTime then 
--         print('Passed', AmountLeft)
--     else
--         print('Still', AmountLeft)
--     end
-- end,false)
--local PassedPayTime, AmountLeft = exports['qr-loan']:DoesPlayerHaveLoan(src)
-- if PassedPayTime and AmountLeft > 0 then
--     TriggerClientEvent('QRCore:Notify', src, 'لا يمكنك القيام بهذا, يوجد لديك قرض بقيمة '..AmountLeft..'$ غير مسدد', 'error')
--     return
-- end

-- RegisterCommand('testloan',function()
--     CrateLoanMenu(GetPlayerServerId(NetworkGetPlayerIndexFromPed(PlayerPedId())))
-- end)

function DoesPlayerHaveLoan(src)
    local xPlayer = QRCore.Functions.GetPlayer(src)
    local license = QRCore.Functions.GetIdentifier(src, "license")
    if xPlayer then
        local Loan = MySQL.scalar.await('SELECT loan FROM loanbank WHERE license = ?', {license})
        local LoanDate = MySQL.scalar.await('SELECT loandate FROM loanbank WHERE license = ?', {license})
        local DateTime = 60 * 60 * 24 * Config.LoanTime
        if Loan > 0 then
            if os.time() > (LoanDate + DateTime) then
                
                return true, Loan
            else
                return false, Loan
            end
        else
            return false, 0
        end
    end
end
exports('DoesPlayerHaveLoan', DoesPlayerHaveLoan)