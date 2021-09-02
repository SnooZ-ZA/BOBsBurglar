ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_burglar:PayMoney')
AddEventHandler('esx_burglar:PayMoney', function()
    xPlayer = ESX.GetPlayerFromId(source)
    PlayerJob = xPlayer.getJob()

    if PlayerJob.name == "burglar" then
        if Config.MoneyType == true then
            xPlayer.addMoney(Config.MoneyAmount)
			TriggerClientEvent('esx:showNotification', source, 'You got $' .. Config.MoneyAmount)
        else
            xPlayer.addAccountMoney('bank', Config.MoneyAmount)
			TriggerClientEvent('esx:showNotification', source, 'You got $' .. Config.MoneyAmount)
        end
    end
end)
