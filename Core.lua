if not IsAddOnLoaded('ElvUI') then return end

local AddonName = ...
local E = unpack(ElvUI)
local Module = E:NewModule('NameShortenerTag')
local Translit = E.Libs.Translit
local translitMark = '!'

local print = print
local type = type
local tonumber = tonumber
local UnitName = UnitName
local UnitNameUnmodified = UnitNameUnmodified

local Private = {}

local category = "Linaori's Tags";

E:AddTagInfo('lin:unit-name', category, 'Unit name which can change based on toys', 1)
E:AddTagInfo('lin:unit-name:translit', category, 'Same as [lin:unit-name] while converting cyrillic', 2)
E:AddTagInfo('lin:real-unit-name', category, 'The real unit name, unaffected by toys', 3)
E:AddTagInfo('lin:real-unit-name:translit', category, 'Same as [lin:real-unit-name] while converting cyrillic', 4)

-- Left to right works in the following steps for 'The Best Warrior Linaori':
-- T. Best Warrior Linaori
-- T.B. Warrior Linaori
-- T.B.W. Linaori
function Private.ReduceLeftToRight(leftPart, rightPart, lastPartLength, nameLength)
    if not rightPart or rightPart:utf8len() == 0 then
        return leftPart, rightPart
    end

    -- 2 spaces added to the length after concat
    if 2 + leftPart:utf8len() + rightPart:utf8len() + lastPartLength <= nameLength then
        return leftPart .. ' ' .. rightPart, ''
    end

    local firstWord, remainingRightPart = rightPart:match('^([^ ]*)[ ](.*)$')
    if not firstWord then
        firstWord = rightPart
        remainingRightPart = ''
    end
    leftPart = leftPart .. firstWord:utf8sub(1, 1) .. '.'

    return Private.ReduceLeftToRight(leftPart, remainingRightPart, lastPartLength, nameLength)
end

-- Right to left works in the following steps for 'The Best Warrior Linaori':
-- The Best W. Linaori
-- The B.W. Linaori
-- T.B.W. Linaori
function Private.ReduceRightToLeft(leftPart, rightPart, lastPartLength, nameLength)
    if not leftPart or leftPart:utf8len() == 0 then
        return leftPart, rightPart
    end

    -- 2 spaces added to the length after concat
    if 2 + leftPart:utf8len() + rightPart:utf8len() + lastPartLength <= nameLength then
        return '', leftPart .. ' ' .. rightPart
    end

    local remainingLeftPart, lastWord = leftPart:match('^(.*)[ ]([^ ]*)$')

    if not remainingLeftPart then
        remainingLeftPart = ''
        lastWord = leftPart
    end

    rightPart = lastWord:utf8sub(1, 1) .. '.' .. rightPart

    return Private.ReduceRightToLeft(remainingLeftPart, rightPart, lastPartLength, nameLength)
end

function Private.CutOffName(wholeName, config)
    if config.noSplitCutoff then
        return wholeName:utf8sub(1, config.length)
    end

    return wholeName
end

function Private.ShortenName(name, config)
    if not name then return end

    local nameLength = config.length

    -- the original name is short enough already
    if name:utf8len() <= nameLength then
        return name
    end

    -- Naming often implies '<name>, <title>' or '<title> <name>'
    if name:find(',') then
        -- assumed that ',' implies a title, and try to strip them of their title
        local possibleName = name:match('^(.*)[,][^,]*$')

        if possibleName then
            if possibleName:utf8len() <= nameLength then
                return possibleName
            end

            -- in case of longer names: 'Linaori the best fury warrior ever, of the deeps
            name = possibleName
        end
    end

    -- Forsworn Squad-Leader -> Forsworn Squad Leader
    -- Squad-Leader of the Forsworn -> Squad Leader of the Forsworn
    if config.hyphenAsSpace then
        local lastPart

        -- keep 'Forsworn Squad-Leader' as is, while still replacing 'Squad-Leader of the Forsworn'
        if config.keepHyphenInLastName then
            local _, spaces = name:gsub(' ', '')
            if spaces > 0 then
                name, lastPart = name:match('^(.*)[ ]([^ ]*)$')
            end
        end

        name = name:gsub('-', ' ')
        if lastPart then
            name = name .. ' ' .. lastPart
        end
    end

    -- amount of times we can check if the name needs replacing
    local _, occurrences = name:gsub(' ', '')

    -- no spaces left to split on, just return whatever can be made of it
    if occurrences == 0 then
        return Private.CutOffName(name, config)
    end

    local nameToShorten, nameToKeep, nameToKeepLength
    if config.keepRightSide then
        -- we always want the last name if possible
        -- example: Cleave Training Dummy -> Dummy
        nameToShorten, nameToKeep = name:match('^(.*)[ ]([^ ]*)$')
        nameToKeepLength = nameToKeep:utf8len()
    else
        -- we always want the first name if possible
        -- example: Cleave Training Dummy -> Cleave
        nameToKeep, nameToShorten = name:match('^([^ ]*)[ ](.*)$')
        nameToKeepLength = nameToKeep:utf8len()
    end

    -- in case the name to keep is too long, just use that
    if nameToKeepLength > nameLength or not config.abbreviate then
        return Private.CutOffName(nameToKeep, config)
    end

    local shortenedName
    if config.abbreviateLeftToRight then
        shortenedName, _ = Private.ReduceLeftToRight('', nameToShorten, nameToKeepLength, nameLength)
    else
        _, shortenedName = Private.ReduceRightToLeft(nameToShorten, '', nameToKeepLength, nameLength)
    end

    if config.keepRightSide then
        return shortenedName .. ' ' .. nameToKeep
    else
        return nameToKeep .. ' ' .. shortenedName
    end
end

function Private.ParseArguments(tagName, input)
    local configTemplate = {
        noSplitCutoff = true,
        length = 20,
        hyphenAsSpace = true,
        keepHyphenInLastName = true,
        keepRightSide = true,
        abbreviate = true,
        abbreviateLeftToRight = false,
    }

    if input then
        for key, value in input:gmatch('%s?(%w+)%s?=%s?(%w+)%s?') do
            local option = configTemplate[key]
            if option ~= nil then
                local valueType = type(option)
                if valueType == 'boolean' then
                    value = value:lower()
                    configTemplate[key] = value == '1' or value == 'true' or value == 'yes'
                elseif valueType == 'number' then
                    local converted = tonumber(value)
                    if converted ~= nil then
                        configTemplate[key] = converted
                    end
                end
            else
                print('Warning: [' .. tagName .. '] option "' .. key .. '" not supported')
            end
        end
    end

    return configTemplate
end

local nameCache = {}

function Private.RegisterTag(tagName, unitNameFunction, doTranslit)
    E:AddTag(tagName, 'UNIT_NAME_UPDATE', function(unit, _, input)
        if not unit then return end

        local name, realm = unitNameFunction(unit)
        if not name then return end

        local cacheKey = (doTranslit and 'T' or '_') .. name .. (realm and ('-' .. realm) or '') .. input

        if not nameCache[cacheKey] then
            local configTemplate = Private.ParseArguments(tagName, input)

            if doTranslit then
                name = Translit:Transliterate(name, translitMark)
            end

            nameCache[cacheKey] = Private.ShortenName(name, configTemplate)
        end

        return nameCache[cacheKey]
    end)
end

Private.RegisterTag('lin:unit-name',               UnitName,           false)
Private.RegisterTag('lin:unit-name:translit',      UnitName,           true)
Private.RegisterTag('lin:real-unit-name',          UnitNameUnmodified, false)
Private.RegisterTag('lin:real-unit-name:translit', UnitNameUnmodified, true)

E:RegisterModule(Module:GetName())
LibStub('LibElvUIPlugin-1.0'):RegisterPlugin(AddonName)
