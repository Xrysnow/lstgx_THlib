List = {}
function List.cons(a,b)
	return {value=a,tail=b}
end

function List.new(a,...)
	if a then
		return List.cons(a,List.new(...))
	else
		return nil
	end
end

function List:reverse()
	local tmp
	while self do
		tmp = {value=self,tail=tmp}
		self = self.tail
	end
	return tmp
end

function Lpairs(list)
	return function(_,node)
		local tmp = node.tail
		if tmp then
			return tmp, tmp.value
		else
			return nil, nil
		end
	end, nil, {tail = list}
end