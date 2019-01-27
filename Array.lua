function table.map(list, fun)
	local tmp = {}
	for i,v in ipairs(list) do
		tmp[i] = fun(v, i)
	end
	return tmp
end
table.collect = table.map
function table.reduce(list, init, fun)
	fun = fun or init
	local index = 1
	if type(init) == 'function' then
		init = list[1]
		index = 2
	end
	for i = index, #list do
		init = fun(init, list[i])
	end
	return init
end
table.inject = table.reduce
function table.all(list, fun)
	for i,v in ipairs(list) do
		if not (v or (fun and fun(v, i))) then
			return false
		end
	end
	return true
end
function table.any(list, fun)
	for i,v in ipairs(list) do
		if v or (fun and fun(v, i)) then
			return true
		end
	end
	return false
end
function table.none(list, fun)
	return not table.any(list, fun)
end
function table.select(list, start, last)
	local tmp = {}
	if type(start) == 'function' then
		for i,v in ipairs(list) do
			if start(v, i) then table.insert(tmp, v) end
		end
	else
		for i = (start or 1),(last or #list) do
			tmp[i] = start[i]
		end
	end
	return tmp
end