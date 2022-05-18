local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

--[ CONEXÃO ]----------------------------------------------------------------------------------------------------------------------------

banK = {}
Tunnel.bindInterface("vrp_banco",banK)
Proxy.addInterface("vrp_banco",banK)


function banK.enableBanking()
    local source = source
    local user_id = vRP.getUserId(source)
    local banco = vRP.getBankMoney(user_id)
    local carteira = vRP.getMoney(user_id)
	local identity = vRP.getUserIdentity(user_id)
    local nome = identity.firstname
    TriggerClientEvent("send:banco",source,banco,carteira,nome,"Indisponivel")
end

function banK.returnMultas()
    local source = source
	local user_id = vRP.getUserId(source)
    local multas = vRP.getUData(user_id,"vRP:multas")
    local int = parseInt(multas)
    return int
end


function banK.quickCash()
	local _source = source
	local user_id = vRP.getUserId(_source)

	amount = tonumber(1000)
	local getbankmoney = vRP.getBankMoney(user_id)

	if amount == nil or amount <= 0 or amount > getbankmoney then
		TriggerClientEvent("Notify",_source,"negado","Valor inválido")
	else
		vRP.tryWithdraw(user_id,amount)
		TriggerClientEvent("Notify",_source,"sucesso","Você sacou <b>$"..amount.." dólares</b>.")
    end
    TriggerClientEvent("banking:updateBalance77784844484",_source,vRP.getBankMoney(user_id),vRP.getMoney(user_id))
end

function banK.dquickCash()
	local _source = source
	local user_id = vRP.getUserId(_source)
	local amount = 1000
	
	if amount == nil or amount <= 0 or amount > vRP.getMoney(user_id) then
		TriggerClientEvent("Notify",_source,"negado","Valor inválido")
	else
		vRP.tryDeposit(user_id, tonumber(amount))
		TriggerClientEvent("Notify",_source,"sucesso","Você depositou <b>$"..amount.." dólares</b>.")
    end
    TriggerClientEvent("banking:updateBalance77784844484",_source,vRP.getBankMoney(user_id),vRP.getMoney(user_id))
end

function banK.sacarDinheiro(valor)
	local _source = source
	local user_id = vRP.getUserId(_source)

	amount = tonumber(valor)
	local getbankmoney = vRP.getBankMoney(user_id)

	if amount == nil or amount <= 0 or amount > getbankmoney then
		TriggerClientEvent("Notify",_source,"negado","Valor inválido")
	else
		vRP.tryWithdraw(user_id,amount)
		TriggerClientEvent("Notify",_source,"sucesso","Você sacou <b>$"..amount.." dólares</b>.")
    end
    TriggerClientEvent("banking:updateBalance77784844484",_source,vRP.getBankMoney(user_id),vRP.getMoney(user_id))
end

function banK.pagarMultas(valor)
	local _source = source
	local user_id = vRP.getUserId(_source)
	local banco = vRP.getBankMoney(user_id)

	local valor = tonumber(valor)

	if banco >= tonumber(valor) then
		local multas = vRP.getUData(user_id,"vRP:multas")
		local int = parseInt(multas)
		if int >= valor then
			if valor > 999 then
				local rounded = math.ceil(valor)
				local novamulta = int - rounded
				vRP.setUData(user_id,"vRP:multas",json.encode(novamulta))
				vRP.setBankMoney(user_id,banco-tonumber(valor))
				TriggerClientEvent("Notify",_source,"sucesso","Você pagou $"..valor.." em multas.")
				TriggerClientEvent("currentbalance2",_source)
			else
				TriggerClientEvent("Notify",_source,"negado","Você só pode pagar multas acima de <b>$1.000</b> dólares")
			end
		else
			TriggerClientEvent("Notify",_source,"negado","Você não pode pagar mais multas do que possuí.")
		end
	else
		TriggerClientEvent("Notify",_source,"negado","Saldo inválido.")
    end
    TriggerClientEvent("banking:updateBalance77784844484",_source,vRP.getBankMoney(user_id),vRP.getMoney(user_id))
end

function banK.depositarDinheiro(amount)
	local _source = source
	local user_id = vRP.getUserId(_source)

	if amount == nil or amount <= 0 or amount > vRP.getMoney(user_id) then
		TriggerClientEvent("Notify",_source,"negado","Valor inválido")
	else
		vRP.tryDeposit(user_id, tonumber(amount))
		TriggerClientEvent("Notify",_source,"sucesso","Você depositou <b>$"..amount.." dólares</b>.")
    end
    TriggerClientEvent("banking:updateBalance77784844484",_source,vRP.getBankMoney(user_id),vRP.getMoney(user_id))
end

--[ SALDO ]------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent('banco:balance')
AddEventHandler('banco:balance', function()
	local _source = source
	local user_id = vRP.getUserId(_source)
	local getbankmoney = vRP.getBankMoney(user_id)
	local multasbalance = vRP.getUData(user_id,"vRP:multas")

    TriggerClientEvent("currentbalance1",_source,addComma(math.floor(getbankmoney)),multasbalance)
    TriggerClientEvent("banking:updateBalance77784844484",_source,vRP.getBankMoney(user_id),vRP.getMoney(user_id))
end)

--[ TRANSFERENCIAS ]---------------------------------------------------------------------------------------------------------------------

RegisterServerEvent('banco:transferir')
AddEventHandler('banco:transferir', function(to,amountt)
	local _source = source
	local user_id = vRP.getUserId(_source)
	local identity = vRP.getUserIdentity(user_id)

	local _nplayer = vRP.getUserSource(parseInt(to))
	local nuser_id = vRP.getUserId(_nplayer)
	local identitynu = vRP.getUserIdentity(nuser_id)
	local banco = 0

	if nuser_id == nil then
		TriggerClientEvent("Notify",_source,"negado","Passaporte inválido ou indisponível.")
	else
		if nuser_id == user_id then
			TriggerClientEvent("Notify",_source,"negado","Você não pode transferir dinheiro para sí mesmo.")	
		else
			local banco = vRP.getBankMoney(user_id)
			local banconu = vRP.getBankMoney(nuser_id)
			
			if banco <= 0 or banco < tonumber(amountt) or tonumber(amountt) <= 0 then
				TriggerClientEvent("Notify",_source,"negado","Dinheiro Insuficiente")
			else
				vRP.setBankMoney(user_id,banco-tonumber(amountt))
				vRP.setBankMoney(nuser_id,banconu+tonumber(amountt))

				TriggerClientEvent("Notify",_nplayer,"sucesso","<b>"..identity.name.." "..identity.firstname.."</b> depositou <b>$"..amountt.." dólares</b> na sua conta.")
				TriggerClientEvent("Notify",_source,"sucesso","Você transferiu <b>$"..amountt.." dólares</b> para conta de <b>"..identitynu.name.." "..identitynu.firstname.."</b>.")
			end
		end
    end
    TriggerClientEvent("banking:updateBalance77784844484",_source,vRP.getBankMoney(user_id),vRP.getMoney(user_id))
end)
