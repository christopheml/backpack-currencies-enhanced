local BCE_Dropdowns = {};
local selectedCurrencyID = nil;

local function RemoveEntry(dropdown)
	if selectedCurrencyID then
		for i=1, C_CurrencyInfo.GetCurrencyListSize() do
			local info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if not info.isHeader then
				local link = C_CurrencyInfo.GetCurrencyListLink(i)
				local id = tonumber(strmatch(link, "currency:(%d+)"))
				if id == selectedCurrencyID then
					C_CurrencyInfo.SetCurrencyBackpack(i, false);
					selectedCurrencyID = nil;
					BackpackTokenFrame_Update();
					TokenFrame_Update();
					return;
				end
			end
		end
	end
end

local function InitDropdownFrame(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.text = GetText("HIDE");
	info.notCheckable = true;
	info.func = RemoveEntry;

	UIDropDownMenu_AddButton(info, nil);
end

local function CreateDropdownFrames()
	for i=1, MAX_WATCHED_TOKENS do
		if not BCE_Dropdowns[i] then
			local parent = _G["BackpackTokenFrameToken"..i];
			BCE_Dropdowns[i] = CreateFrame("Button", "BCE_DropdownFrame" .. i, parent, "UIDropDownMenuTemplate");
			UIDropDownMenu_Initialize(BCE_Dropdowns[i], InitDropdownFrame, "MENU");
		end
	end
end

local function BringUpCurrenciesFrame()
	ToggleCharacter("TokenFrame");
end

local function BackpackFrameClickHook(self, button)
	if button == "LeftButton" then
		BringUpCurrenciesFrame();
	end
end

local function CurrencyClickHook(self, button)
	if button == "LeftButton" then
		BringUpCurrenciesFrame();
	elseif button == "RightButton" then
		for i=1, MAX_WATCHED_TOKENS do
			local parent = BCE_Dropdowns[i]:GetParent();
			if parent == self then
				selectedCurrencyID = parent.currencyID;
				ToggleDropDownMenu(1, nil, BCE_Dropdowns[i], "cursor", 3, -3);
			end
		end
	end;
end

-- Formats huge numbers in thousands to allow number the default interface would render as "*"
local function FormatCount(count)
	if count <= 99999 then
		return count;
	else
		return string.format("%dk", count / 1000);
	end
end

local function ColorCount(count, maximum)
	if maximum and maximum > 0 then
		local ratio = count / maximum;
	
		if ratio == 1 then
			return 1, 0, 0, 1;
		elseif ratio > 0.8 then
			return 1, 0.63, 0.17, 1;
		end
	end

	return 1, 1, 1, 1;
end

local function BackpackTokenFrame_UpdateHook()
	for i=1, MAX_WATCHED_TOKENS do
		local watchButton = _G["BackpackTokenFrameToken"..i];
		local _, count, _, currencyID = C_CurrencyInfo.GetBackpackCurrencyInfo(i);
		
		if count then
			-- Custom coloring for cap
			local maximum = select(6, C_CurrencyInfo.GetCurrencyInfo(currencyID));
			watchButton.count:SetTextColor(ColorCount(count, maximum));

			-- Enhanced formatting
			watchButton.count:SetText(FormatCount(count));
		end
	end
end

local function Init(...)
	local addonName = select(3, ...);
	
	if addonName == "BackpackCurrenciesEnhanced" then
		BCE_Frame:UnregisterAllEvents()

		CreateDropdownFrames();
		
		local backpackFrame = _G["BackpackTokenFrame"]
		backpackFrame:EnableMouse(true);
		
		-- Hook on the back frame
		backpackFrame:HookScript("OnMouseUp", BackpackFrameClickHook);
		
		-- Hook on the individual currencies
		for i=1, MAX_WATCHED_TOKENS do
			local watchButton = _G["BackpackTokenFrameToken"..i];
			watchButton:RegisterForClicks("AnyUp");
			watchButton:HookScript("OnClick", CurrencyClickHook);
		end
		
		-- Hook the rendering of the currency buttons to fix the count if > 99999
		hooksecurefunc("BackpackTokenFrame_Update", BackpackTokenFrame_UpdateHook);
	end
end		

-- Bootstrap
local BCE_Frame = CreateFrame("Frame", "BCE_Frame", UIParent);
BCE_Frame:SetScript("OnEvent", Init);
BCE_Frame:RegisterEvent("ADDON_LOADED");
