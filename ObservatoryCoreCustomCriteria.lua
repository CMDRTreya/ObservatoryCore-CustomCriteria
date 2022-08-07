::Global::

-- Options ------------------------------------------------------------------------------
-- Prepending lines with '--' deactivates a check/notification

-- For Horizons Bio signals
notifyNoAtmoBio = true

-- Notification for unmapped valuables
-- left side is the actual value as defined in Journal docs
-- right side is used for the notification text
notifyValuables = true
highValuePlanet = {
    ['Earthlike body']               = 'Earthlike',
    ['Water world']                  = 'Water World',
    ['Ammonia world']                = 'Ammonia World',
    -- ['Metal rich body']              = 'Metal Rich',
    -- ['Sudarsky class II gas giant']  = 'Class 2 Gas Giant',
}

notifyUncommonStars = true
uncommonStars = {
    -- ['TTS']                     = 'T Tauri',
    ['AeBe']                    = 'Herbig Ae/Be',

    ['W']                       = 'Wolf-Rayet W',
    ['WN']                      = 'Wolf-Rayet WN',
    ['WNC']                     = 'Wolf-Rayet WNC',
    ['WC']                      = 'Wolf-Rayet WC',
    ['WO']                      = 'Wolf-Rayet WO',
    
    ['CS']                      = 'Carbon CS',
    ['C']                       = 'Carbon C',
    ['CN']                      = 'Carbon CN',
    ['CJ']                      = 'Carbon CJ',
    ['CH']                      = 'Carbon CH',
    ['CHd']                     = 'Carbon CHd',
    ['MS']                      = 'Carbon MS',
    ['S']                       = 'Carbon S',
    
    ['A_BlueWhiteSuperGiant']   = 'A Blue White Super Giant',
    ['F_WhiteSuperGiant']       = 'F White Super Giant',
    ['M_RedSuperGiant']         = 'M Red Super Giant',
    ['M_RedGiant']              = 'M Red Giant',
    ['K_OrangeGiant']           = 'K Orange Giant',

    ['D']                       = 'White Dwarf D',
    -- ['DA']                      = 'White Dwarf DA',
    ['DAB']                     = 'White Dwarf DAB',
    ['DAO']                     = 'White Dwarf DAO',
    ['DAZ']                     = 'White Dwarf DAZ',
    ['DAV']                     = 'White Dwarf DAV',
    ['DB']                      = 'White Dwarf DB',
    ['DBZ']                     = 'White Dwarf DBZ',
    ['DBV']                     = 'White Dwarf DBV',
    ['DO']                      = 'White Dwarf DO',
    ['DOV']                     = 'White Dwarf DOV',
    ['DQ']                      = 'White Dwarf DQ',
    -- ['DC']                      = 'White Dwarf DC',
    ['DCV']                     = 'White Dwarf DCV',
    ['DX']                      = 'White Dwarf DX',

    -- ['N']                       = 'Neutron',
    ['H']                       = 'Black Hole',
    ['SupermassiveBlackHole']   = 'Supermassive Black Hole',
    -- Never say never
    ['X']                       = 'Exotic',
    ['RoguePlanet']             = 'Rogue Planet',
    ['Nebula']                  = 'Nebula',
    ['StellarRemnantNebula']    = 'Stellar Remnant Nebula',
}

-- Notification for high/low gravity landables
thresholdLowG  = 0.03
thresholdHighG = 5

-- Notification for undiscovered systems
-- notifyUndiscovered = true

-- Notification for small landables
-- radius in km
thresholdRadius = 300

-- Notification for planets with geo signals and favorable Selenium distribution
-- Assigned value is minimum gravity needed to trigger
-- Great: Se content is higher than all other common mats combined
-- Good:  Se content is higher than half of all other common mats combined
notifyGreatSelenium = 0
notifyGoodSelenium = 0.7 -- lower Se content but fast falling chunks

-- Notification for Helium rich regions
-- value in percent
MINIMUM_HELIUM_FOR_NOTIFICATION = 29.5

-- if true formats numbers as 1.234.567,89 instead of 1,234,567.89
useCommaDecimals = true

-- End of options -----------------------------------------------------------------------

last_helium_boxel = ''

common = {
    ['arsenic']    = true,
    ['chromium']   = true,
    ['germanium']  = true,
    ['manganese']  = true,
    ['vanadium']   = true,
    ['zinc']       = true,
    ['zirconium']  = true,
}

-- based partially on http://lua-users.org/wiki/FormattingNumbers
-- optionally applies format like string.format() would
-- inserts thousands separator into val
-- returns non-numbers unchanged
-- if global useCommaDecimals is true returns formatNumber(1234567, '%.3f') as "1.234.567,000"
--  otherwise as "1,234,567.000"
function formatNumber(val, format)
    local ret = val
    if type(val) == 'number' then
        local separator = ','
        if format then
            ret = string.format(format, val)
        end
        if useCommaDecimals then
            separator = '.'
            ret = string.gsub(ret, '%.', ',')
        end
        repeat
            ret, subs = string.gsub(ret, "^(-?%d+)(%d%d%d)", '%1' .. separator .. '%2')
        until subs == 0
    end
    return ret
end

function convertToStandardGravity(value) return value / 9.80665 end
function convertToMSecSqur(value) return value * 9.80665 end

function string.startsWith(String,Start)
    if (String == nil) then
        return false
    end
    return string.sub(String,1,string.len(Start))==Start
end

-- avoids unnecessary conversions during individual checks 
if thresholdLowG then thresholdLowG = convertToMSecSqur(thresholdLowG) end
if thresholdHighG then thresholdHighG = convertToMSecSqur(thresholdHighG) end
if thresholdRadius then thresholdRadius = thresholdRadius * 1000 end
if notifyGoodSelenium then notifyGoodSelenium = convertToMSecSqur(notifyGoodSelenium) end
if notifyGreatSelenium then notifyGreatSelenium = convertToMSecSqur(notifyGreatSelenium) end
::End::


-- Notifies once per boxel if helium content is above threshold
-- Courtesy of CMDR Matt G
-- https://discord.com/channels/787793855252660235/787793855981944885/1000027238940561428
::Criteria::
if(scan.StarSystem and scan.PlanetClass and (string.match(scan.PlanetClass,'Helium') or string.match(scan.PlanetClass,'Sudarsky'))) then
    this_boxel = scan.StarSystem:gsub('[%d-]+$','')
    if(this_boxel ~= last_helium_boxel) then
        for mat in materials(scan.AtmosphereComposition) do
            if mat.name == 'Helium' and mat.percent >= MINIMUM_HELIUM_FOR_NOTIFICATION then
                last_helium_boxel = this_boxel
                return true,'Possible High Helium Boxel',string.format("%.2f",mat.percent) .. '% Helium seen'
            end
        end
    end
end
::End::


-- brain trees
-- temp below 500K
-- volcanism
-- no atmosphere

::Bio on vacuum landable::
notifyNoAtmoBio and biosignals > 0 and scan.AtmosphereType == 'None'
::Detail::
'Temp: ' .. formatNumber(scan.SurfaceTemperature, '%.0f') .. ' K, Dist: ' .. formatNumber(math.ceil(scan.DistanceFromArrivalLS)) .. ' ls, Grav: ' .. formatNumber(convertToStandardGravity(scan.SurfaceGravity), '%.2f') .. ' g\n' .. (scan.Volcanism or 'No volcanism')


::Bio signals::
biosignals > 4


-- Landable High/Low Gravity
::Criteria::
if (thresholdHighG or thresholdLowG) and scan.Landable then
    local highLow
    local dec = '%.2f'
    if thresholdHighG and scan.SurfaceGravity > thresholdHighG then
        highLow = 'High'
    end
    if thresholdLowG and scan.SurfaceGravity < thresholdLowG then
        highLow = 'Low'
        dec = '%.3f'
    end
    if highLow then
        return true, 'Landable ' .. highLow .. ' Gravity', formatNumber(convertToStandardGravity(scan.SurfaceGravity), dec) .. ' g'
    end
end
::End::


::High Mass Landable::
scan.Landable and scan.MassEM > 5
::Detail::
'Mass: ' .. formatNumber(scan.MassEM, "%.1f") .. ' EM\nRadius: ' .. formatNumber(math.ceil(scan.Radius / 1000)) .. ' km\n Gravity: ' .. formatNumber(convertToStandardGravity(scan.SurfaceGravity), "%.2f") .. " g"


::Small landable::
thresholdRadius and scan.Landable and scan.Radius < thresholdRadius
::Detail::
'Radius: ' .. formatNumber(math.ceil(scan.Radius / 1000)) .. ' km'

::Uncommon Star::
notifyUncommonStars and (uncommonStars[scan.StarType] ~= nil)
::Detail::
uncommonStars[scan.StarType]


::Helium Gas Giant::
scan.PlanetClass == "Helium gas giant"


-- Unmapped valuables
-- TODO proper planetType mapping for Rocky/Metallic
::Criteria::
local planetType

if notifyValuables then
    if highValuePlanet[scan.PlanetClass] and not scan.WasMapped then
        planetType = highValuePlanet[scan.PlanetClass]
        -- if scan.TerraformState  and #scan.TerraformState > 0 then
        --     planetType = 'Terraformable ' .. planetType
        end
    if scan.TerraformState and #scan.TerraformState > 0 and not scan.WasMapped then
        if not planetType then
            planetType = scan.PlanetClass
        end
        planetType = 'Terraformable ' .. planetType
    end
    
    if planetType then
        return true, 'Unmapped ' .. planetType, 'Distance: ' .. formatNumber(math.ceil(scan.DistanceFromArrivalLS)) .. ' ls'
    end
end
::End::

-- Based on
-- https://forums.frontier.co.uk/threads/elite-observatory-search-your-journal-for-potentially-interesting-objects-or-Notification foru-of-new-ones-on-the-fly-while-exploring.521544/post-9855105
-- Added on/off options and minimum gravity thresholds
::Criteria::
if scan.Landable and scan.Materials and geosignals > 0 then
    local commonMatsPercent = 0
    local seleniumPercent = 0
    local quality
    
    if notifyGreatSelenium or notifyGoodSelenium then
        for mat in materials(scan.Materials) do
            if mat.name == 'selenium' then
                seleniumPercent = mat.percent
            elseif common[mat.name] then
                commonMatsPercent = commonMatsPercent + mat.percent
            end
        end
        
        if notifyGreatSelenium and seleniumPercent > commonMatsPercent and scan.SurfaceGravity > notifyGreatSelenium then
            quality = 'Great'
        elseif notifyGoodSelenium and seleniumPercent > commonMatsPercent * 0.5 and scan.SurfaceGravity > notifyGoodSelenium then
            quality = 'Good'
        end
        
        if quality then
            return true, quality .. ' Selenium Source', formatNumber(seleniumPercent, '%.1f') .. '%'
        end
    end
end
::End::

-----------------------------------------------------------------------------------------------
-- Below: Unmodified excerpts from https://cdn.discordapp.com/attachments/916086414943354890/951307948280397884/TME_Custom.lua


::Undiscovered System::
notifyUndiscovered and scan.ScanType ~= "NavBeaconDetail" and scan.PlanetClass ~= "Barycentre" and not scan.WasDiscovered and scan.DistanceFromArrivalLS == 0


-- Find Ringed M Stars, Neutron Stars and White Dwarfs
::Criteria::
if (scan.StarType == 'M' or scan.StarType == 'N' or string.startsWith(scan.StarType, "D")) and scan.Rings then
  for ring in rings(scan.Rings) do
      if (string.find(ring.name, "Ring")) then
        local starTypeDesc = 'Neutron'
        if string.startsWith(scan.StarType, "D") then
          starTypeDesc = 'White Dwarf ('.. scan.StarType .. ')'
        elseif scan.StarType == 'M' then
          starTypeDesc = 'M-class'
        end
        return true, 'Ringed '.. starTypeDesc ..' Star', ''
      end
  end
end
::End::


--[[
Criteria for detecting "Taylor's Rings"
named after Elizabeth Taylor's incredibly thin rings.
Found in E:O discord
--]]

::Criteria::
if (scan.Rings and scan.Rings.Count == 1 and string.find(scan.Rings[0].Name, ' Ring') and ((scan.Rings[0].OuterRad - scan.Rings[0].InnerRad) / scan.Radius < 0.25)) then
  return true, "Taylor's Ring", 'Ring width: ' .. math.floor((scan.Rings[0].OuterRad - scan.Rings[0].InnerRad) / 1000)..", "..scan.PlanetClass .. ", " .. math.floor(scan.DistanceFromArrivalLS) .. " Ls"
end
::End::
