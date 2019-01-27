Queue = {}

function Queue:push(item,...)
	if item then
		self[self.start+self.n]=item
		self.n = self.n + 1
		return self:push(...)
	else
		return self
	end
end

function Queue:pop()
	local cache = self:first()
	self[self.start] = nil
	self.start = self.start + 1
	self.n = self.n - 1
	return cache
end

function Queue:first()
	return self[self.start]
end

function Queue:back()
	return self[self.start+self.n-1]
end

function Queue:get(index)
	return self[self.start+index-1]
end

function Queue.new(...)
	local obj = arg
	obj.n = #obj
	obj.start = 0
	setmetatable(obj,{__index = Queue})
	return obj
end

function Qpairs(que)
	return function(q,i)
		if i < q.n then
			return i+1,q:get(i+1)
		else
			return nil,nil
		end
	end,que,0
end