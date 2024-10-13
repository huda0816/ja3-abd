function OnMsg.DataLoaded()
	local equippedSet = HUDA_CustomSettingsUtils.XTemplate_FindElementsByProp(XTemplates["UIWeaponDisplay"], "Id",
		"idFrame")

	if equippedSet then
		if equippedSet.element[1].Id == "idButtonsLeft" then
			table.remove(equippedSet.element, 1)
		end

		table.insert(equippedSet.element, 1, PlaceObj('XTemplateWindow', {
			'Id', "idButtonsLeft",
			'Margins', box(0, 0, -2, -2),
			'Dock', "left",
			'LayoutMethod', "VList",
			'UniformRowHeight', true,
			'Background', RGBA(52, 55, 60, 255),
			'BackgroundRectGlowSize', 1,
			'BackgroundRectGlowColor', RGBA(52, 55, 60, 255),
		}, {
			PlaceObj('XTemplateForEach', {
				'comment', "lighttypes",
				"__context",
				function(parent, context, item, i, n)
					return item
				end,
				'array', function(parent, context)
				return ABD_Flashlight.lightTypes
			end,

				'run_after', function(child, context, item, i, n, last)
				if child then
					if child.idIcon then
						child.idIcon:SetImage(item.icon)
					end
				end
			end,
			}, {
				PlaceObj('XTemplateWindow', {
					'__condition', function(parent, context)
					return ABD_Flashlight:HasLightMod(SelectedObj, context.type)
				end,
					'__class', "XButton",
					'RolloverTemplate', "CombatActionRollover",
					'RolloverAnchor', "bottom-right",
					'RolloverAnchorId', "idWeaponUI",
					'RolloverOffset', box(20, 0, 0, 0),
					'Margins', box(0, -2, 0, 0),
					'BorderWidth', 2,
					'Padding', box(3, 0, 3, 0),
					'MinWidth', 30,
					'MaxWidth', 30,
					'BorderColor', RGBA(52, 55, 61, 255),
					'Background', RGBA(32, 35, 47, 255),
					'FXMouseIn', "buttonRollover",
					'FXPress', "ChangeWeapon",
					'FXPressDisabled', "IactDisabled",
					'FocusedBackground', RGBA(0, 0, 0, 0),
					'DisabledBorderColor', RGBA(52, 55, 61, 255),
					'DisabledBackground', RGBA(32, 35, 47, 125),
					'OnPress', function(self, gamepad)
					local context = self:GetContext()
					ABD_Flashlight:HandleLightToggle(SelectedObj, context.type)
				end,
					'RolloverBackground', RGBA(0, 0, 0, 0),
					'PressedBackground', RGBA(0, 0, 0, 0),
				}, {
					PlaceObj('XTemplateWindow', {
						'__class', "XImage",
						'Id', "idIcon",
						'HAlign', "center",
						'VAlign', "center",
						'Image', "Mod/D55GHCb/icons/flashlight.png",
						'ImageColor', RGBA(195, 189, 172, 255),
						'ImageFit', "width",
					}),
					PlaceObj('XTemplateFunc', {
						'name', "SetEnabled(self, enabled)",
						'func', function(self, enabled)
						XButton.SetEnabled(self, enabled)
						self.idIcon:SetTransparency(enabled and 0 or 160)
					end,
					}),
				}),
			})
		}))
	end
end
