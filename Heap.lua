Heap={}

function Heap:__push(item)
	table.insert(self,item)
	local i = #self
	while i~=1 do
		local parent = math.floor(i/2)
		if self[parent] > self[i] then
			local tmp = self[i]
			self[i]=self[parent]
			self[parent]=tmp
		else
			break
		end
		i = parent
	end
	return self
end

function Heap:push(item,...)
	if item then
		return self
	else
		self:__push(item)
		return self:push(...)
	end
end

function Heap:pop()
	local cache = self[1]
	local max = #self
	self[1] = self[max]
	table.remove(self)
	local i = 1
	max = max - 1
	while i < max do
		local child = i * 2
		if self[child] and self[child]<self[i] then
			if self[child+1] and self[child+1]<self[child] then
				child = child + 1
			end
		elseif self[child+1] and self[child+1]<self[i] then
			child = child + 1
		else
			break
		end
		local tmp = self[i]
		self[i]=self[child]
		self[child]=tmp
		i = child
	end
	return cache
end

function Heap:min()
	return self[1]
end

function Heap.new(...)
	local obj = arg
	table.sort(arg)
	setmetatable(obj,{__index=Heap})
	return obj
end