BoAmmoClip = BoAmmoClip or class(AmmoClip)

function BoAmmoClip:init(unit)
	BoAmmoClip.super.init(self, unit)

	self._ammo_box = true
	self:reload_contour()
end