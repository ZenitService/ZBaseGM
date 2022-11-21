RegisterServerEvent('saveskintodb')
AddEventHandler('saveskintodb', function(skin)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.update('UPDATE users SET skin = ? WHERE identifier = ?', {
        json.encode(skin), 
        xPlayer.identifier
    }, function(affectedRows)
        -- if affectedRows then
        --     print(affectedRows)
        -- end
    end)
end)