function UnitProperties:SelectArchetype(proto_context)
	if IsKindOf(self, "Unit") then
		self.current_archetype = ABD_AI:GetArchetype(self, proto_context)
	end
end
