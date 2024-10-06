UndefineClass('FlareAmmo')
DefineClass.FlareAmmo = {
	__parents = { "Ordnance" },
	__generated_by_class = "ModItemInventoryItemCompositeDef",


	object_class = "Ordnance",
	Repairable = false,
	Icon = "UI/Icons/Items/FlareBullet",
	DisplayName = T(253255482100, --[[ModItemInventoryItemCompositeDef FlareAmmo DisplayName]] "Flare Cartridge"),
	DisplayNamePlural = T(645716581676, --[[ModItemInventoryItemCompositeDef FlareAmmo DisplayNamePlural]] "Flare Cartridges"),
	Description = T(754505471396, --[[ModItemInventoryItemCompositeDef FlareAmmo Description]] "Ammo for the Flare Gun."),
	Cost = 100,
	CanAppearInShop = true,
	MaxStock = 5,
	RestockWeight = 30,
	CategoryPair = "UtilityAmmo",
	AreaOfEffect = 12,
	PenetrationClass = 1,
	Caliber = "Flare",
	BaseDamage = 0,
	Noise = 0,
}

