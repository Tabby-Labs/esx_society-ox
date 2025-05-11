local function withdrawSocietyMoney(society)
	local input = lib.inputDialog(TranslateCap('withdraw_amount'), {
		{type = 'number', label = TranslateCap('amount_title'), min = 1, max = 250000, description = TranslateCap('withdraw_amount_placeholder'), required = true}
	})

	if input and input[1] then
		local amount = input[1]
		if not amount or amount < 1 then 
			lib.notify({
				description = TranslateCap('invalid_value'),
				type = 'error'
			})
			return
		end
		TriggerServerEvent('esx_society:withdrawMoney', society, amount)
	end
end

local function depositSocietyMoney(society)
	local input = lib.inputDialog(TranslateCap('deposit_amount'), {
		{type = 'number', label = TranslateCap('amount_title'), min = 1, max = 250000, description = TranslateCap('deposit_amount_placeholder'), required = true}
	})

	if input and input[1] then
		local amount = input[1]
		if not amount or amount < 1 then 
			lib.notify({
				description = TranslateCap('invalid_value'),
				type = 'error'
			})
			return
		end
		TriggerServerEvent('esx_society:depositMoney', society, amount)
	end
end

local function washSocietyMoney(society)
	local input = lib.inputDialog(TranslateCap('wash_money'), {
		{type = 'number', label = TranslateCap('amount_title'), min = 1, max = 250000, description = TranslateCap('money_wash_amount_placeholder'), required = true}
	})
	if input and input[1] then
		local amount = input[1]
		if not amount or amount < 1 then 
			lib.notify({
				description = TranslateCap('invalid_value'),
				type = 'error'
			})
			return
		end
		TriggerServerEvent('esx_society:washMoney', society, amount)
	end
end

local function openEmployeeAction(society, employee, options)
	local elements = {
		id = 'employee_action',
		title = TranslateCap('employees_title'),
		options = {
			{
				icon = 'fas fa-user',
				title = TranslateCap('promote'),
				onSelect = function()
					local emp = employee
					OpenPromoteMenu(society, emp, options)
				end,
			},
			{
				icon = 'fas fa-user',
				title = TranslateCap('fire'),
				onSelect = function()
					local emp = employee
					ESX.ShowNotification(TranslateCap('you_have_fired', emp.name))

					ESX.TriggerServerCallback('esx_society:setJob', function()
						ESX.TriggerServerCallback('esx_society:isBoss', function(isBoss)
							if not isBoss then return end
							OpenEmployeeList(society, options)
						end)
					end, emp.identifier, 'unemployed', 0, 'fire')
				end
			}
		}
	}

	elements.options[#elements.options+1] = {
		icon = 'fas fa-arrow-left',
		title = TranslateCap('return'),
		onSelect = function()
			OpenEmployeeList(society, options)
		end
	}

	lib.registerContext(elements)
	lib.showContext(elements.id)
end

local function setSocietySalary(society, grade, options)
	local input = lib.inputDialog(TranslateCap('salary_management'), {
		{type = 'number', label = TranslateCap('amount_title'), min = 1, max = Config.MaxSalary, description = TranslateCap('change_salary_placeholder'), required = true}
	})

	if input and input[1] then
		local amount = input[1]
		if not amount or amount < 1 then 
			lib.notify({
				description = TranslateCap('invalid_value'),
				type = 'error'
			})
			return
		end

		if amount > Config.MaxSalary then
			ESX.ShowNotification(TranslateCap('invalid_value_nochanges'))
			OpenManageSalaryMenu(society, options)
			return
		end

		ESX.TriggerServerCallback('esx_society:setJobSalary', function()
			OpenManageSalaryMenu(society, options)
		end, society, grade, amount)
	end
end

local function manageSocietyGrade(society, grade, options)
		local input = lib.inputDialog(TranslateCap('grade_management'), {
		{type = 'input', label = TranslateCap('change_label_title'), min = 1, max = 25000, description = TranslateCap('change_label_description'), required = true}
	})

	if input and input[1] then
		local label = input[1]
		if not label then 
			lib.notify({
				description = TranslateCap('invalid_value_nochanges'),
				type = 'error'
			})
			return
		end

		ESX.TriggerServerCallback('esx_society:setJobLabel', function()
			OpenManageGradesMenu(society, options)
		end, society, grade, label)
	end
end

function OpenBossMenu(society, options)
	options = options or {}

	ESX.TriggerServerCallback('esx_society:isBoss', function(isBoss)
		local elements = {
			id = 'boss_menu',
			title = TranslateCap('boss_menu'),
			options = {},
		}

		if not isBoss then return end
		
		local defaultOptions = {
			checkBal = true,
			withdraw = true,
			deposit = true,
			wash = true,
			employees = true,
			salary = true,
			grades = true
		}

		for k, v in pairs(defaultOptions) do
			if options[k] == nil then
				options[k] = v
			end
		end

		if options.checkBal then
			elements.options[#elements.options+1] = {
				icon = 'fas fa-wallet',
				title = TranslateCap('check_society_balance'),
				onSelect = function()
					TriggerServerEvent('esx_society:checkSocietyBalance', society)
				end,
			}
		end

		if options.withdraw then
			elements.options[#elements.options+1] = {
				icon = 'fas fa-wallet',
				title = TranslateCap('withdraw_society_money'),
				onSelect = function()
					withdrawSocietyMoney(society)
				end
			}
		end

		if options.deposit then
			elements.options[#elements.options+1] = {
				icon = 'fas fa-wallet',
				title = TranslateCap('deposit_society_money'),
				onSelect = function()
					depositSocietyMoney(society)
				end
			}
		end

		if options.wash then
			elements.options[#elements.options+1] = {
				icon = 'fas fa-wallet',
				title = TranslateCap('wash_money'),
				onSelect = function()
					washSocietyMoney(society)
				end
			}
		end

		if options.employees then
			elements.options[#elements.options+1] = {
				icon = 'fas fa-users',
				title = TranslateCap('employee_management'),
				onSelect = function()
					OpenManageEmployeesMenu(society, options)
				end
			}
		end
			
		if options.salary then
			elements.options[#elements.options+1] = {
				icon = 'fas fa-wallet',
				title = TranslateCap('salary_management'),
				onSelect = function()
					OpenManageSalaryMenu(society, options)
				end
			}
		end

		if options.grades then
			elements.options[#elements.options+1] = {
				icon = 'fas fa-scroll',
				title = TranslateCap('grade_management'),
				onSelect = function()
					-- value 'manage_grades'
					OpenManageGradesMenu(society, options)
				end
			}
		end

		lib.registerContext(elements)
		lib.showContext(elements.id)
	end, society)
end

function OpenManageEmployeesMenu(society, options)
	local elements = {
		id = 'manage_employees',
		title = TranslateCap('employee_management'),
		options = {
			{
				icon = 'fas fa-users',
				title = TranslateCap('employee_list'),
				onSelect = function()
					OpenEmployeeList(society, options)
				end
			},
			{
				icon = 'fas fa-users',
				title = TranslateCap('recruit'),
				onSelect = function()
					OpenRecruitMenu(society, options)
				end
			},
		}
	}

	elements.options[#elements.options+1] = {
		icon = 'fas fa-arrow-left',
		title = TranslateCap('return'),
		onSelect = function()
			OpenBossMenu(society, options)
		end
	}

	lib.registerContext(elements)
	lib.showContext(elements.id)
end

function OpenEmployeeList(society, options)
	ESX.TriggerServerCallback('esx_society:getEmployees', function(employees)
		local elements = {
			id = 'employee_list',
			title = TranslateCap('employees_title'),
			options = {}
		}

		for i=1, #employees, 1 do
			local emp = employees[i]
			local gradeLabel = (employees[i].job.grade_label == '' and employees[i].job.label or employees[i].job.grade_label)

			elements.options[#elements.options+1] = {
				icon = 'fas fa-user',
				title = ('%s | %s'):format(employees[i].name, gradeLabel),
				onSelect = function()
					openEmployeeAction(society, emp, options)
				end
			}

		end

		elements.options[#elements.options+1] = {icon = "fas fa-arrow-left", title = TranslateCap('return'), onSelect = function() OpenManageEmployeesMenu(society, options) end}

		lib.registerContext(elements)
		lib.showContext(elements.id)
	end, society)
end

function OpenRecruitMenu(society, options)
	ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
		local elements = {
			id = 'recruit_menu',
			title = TranslateCap('recruiting'),
			options = {}
		}

		for i=1, #players, 1 do
			local player = players[i]
			if player.job.name ~= society then
				elements.options[#elements.options+1] = {
					icon = 'fas fa-user',
					title = player.name,
					onSelect = function()
						local alert = lib.alertDialog({
							header = TranslateCap('recruiting'),
							content = ('%s'):format(player.name),
							centered = true,
							cancel = true
						})
						
						if alert then
							ESX.ShowNotification(TranslateCap('you_have_hired', player.name))

							ESX.TriggerServerCallback('esx_society:setJob', function()
								OpenRecruitMenu(society, options)
							end, player.identifier, society, 0, 'hire')
						end
					end
				}
			end
		end

		elements.options[#elements.options+1] = {icon = "fas fa-arrow-left", title = TranslateCap('return'), onSelect = function() OpenManageEmployeesMenu(society, options) end}

		lib.registerContext(elements)
		lib.showContext(elements.id)
	end)
end

function OpenPromoteMenu(society, employee, options)
	ESX.TriggerServerCallback('esx_society:getJob', function(job)
		if not job then
			return
		end
		local elements = {
			id = 'promote_menu',
			title = TranslateCap('promote_employee', employee.name),
			options = {}
		}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			elements.options[#elements.options+1] = {
				icon = 'fas fa-user',
				title = gradeLabel,
				onSelect = function()
					ESX.ShowNotification(TranslateCap('you_have_promoted', employee.name, grade))

					ESX.TriggerServerCallback('esx_society:setJob', function()
						OpenEmployeeList(society, options)
					end, employee.identifier, society, job.grades[i].grade, 'promote')
				end
			}
		end

		elements.options[#elements.options+1] = {
			icon = 'fas fa-arrow-left',
			title = TranslateCap('return'),
			onSelect = function()
				OpenEmployeeList(society, options)
			end
		}

		lib.registerContext(elements)
		lib.showContext(elements.id)
	end, society)
end

function OpenManageSalaryMenu(society, options)
	ESX.TriggerServerCallback('esx_society:getJob', function(job)
		if not job then
			return
		end

		local elements = {
			id = 'salary_management_menu',
			title = TranslateCap('salary_management'),
			options = {}
		}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			elements.options[#elements.options+1] = {
				icon = "fas fa-wallet",
				title = ('%s - %s'):format(gradeLabel, TranslateCap('money_generic', ESX.Math.GroupDigits(job.grades[i].salary))),
				onSelect = function()
					setSocietySalary(society, job.grades[i].grade, options)
				end
			}
		end
			
		elements.options[#elements.options+1] = {icon = "fas fa-arrow-left", title = TranslateCap('return'), onSelect = function() OpenBossMenu(society, options) end}

		lib.registerContext(elements)
		lib.showContext(elements.id)
	end, society)
end

function OpenManageGradesMenu(society, options)
	ESX.TriggerServerCallback('esx_society:getJob', function(job)
		if not job then
			return
		end

		local elements = {
			id = 'manage_grades_menu',
			title = TranslateCap('grade_management'),
			options = {}
		}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			elements.options[#elements.options+1] = {
				icon = 'fas fa-wallet',
				title = ('%s'):format(gradeLabel),
				onSelect = function()
					manageSocietyGrade(society, job.grades[i].grade, options)
				end
			}
		end
			
		elements.options[#elements.options+1] = {icon = "fas fa-arrow-left", title = TranslateCap('return'), onSelect = function() OpenBossMenu(society, options) end}

		lib.registerContext(elements)
		lib.showContext(elements.id)
	end, society)
end

AddEventHandler('esx_society:openBossMenu', function(society, close, options)
	OpenBossMenu(society, options)
	print(close)
end)
