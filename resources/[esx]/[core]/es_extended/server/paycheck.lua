StartPayCheck = function()
	Citizen.CreateThread(function()
		while true do
			local xPlayers = ESX.GetExtendedPlayers()
			for _, xPlayer in pairs(xPlayers) do
				local job = xPlayer.job.grade_name
				local salary = xPlayer.job.grade_salary
				if salary > 0 then
					if job == 'unemployed' then
						xPlayer.addAccountMoney('bank', salary)
						xPlayer.showNotification('Hai ricevuto il tuo aiuto di: '..salary..'$')
					elseif Config.EnableSocietyPayouts then
						TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
							if society ~= nil then
								TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
									if account.money >= salary then
										xPlayer.addAccountMoney('bank', salary)
										account.removeMoney(salary)
										xPlayer.showNotification('Hai ricevuto il tuo stipendio di: '..salary..'$')
									else
										xPlayer.showNotification('La società non ha abbastanza soldi per pagarti')
									end
								end)
							else
								xPlayer.addAccountMoney('bank', salary)
								xPlayer.showNotification('Hai ricevuto il salario di: '..salary..'$')
							end
						end)
					else
						xPlayer.addAccountMoney('bank', salary)
						xPlayer.showNotification('Hai ricevuto il salario di: '..salary..'$')
					end
				end
			end
			Citizen.Wait(Config.PaycheckInterval)
		end
	end)
end
