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

local function FormatCount(count)
	-- Borrowed from Blizzard API now they got the formatting right :-)
	local currencyText = BreakUpLargeNumbers(count);
	if strlenutf8(currencyText) > 5 then
		currencyText = AbbreviateNumbers(count);
	end
	return currencyText
end

local function ColorCount(count, maximum)

	local function ExplodeToRGB(color)
		return color.r, color.g, color.b
	end

	if maximum and maximum > 0 then
		local ratio = count / maximum;
	
		if ratio == 1 then
			return ExplodeToRGB(RED_FONT_COLOR);
		elseif ratio > 0.8 then
			return ExplodeToRGB(ORANGE_FONT_COLOR);
		end
	end

	return ExplodeToRGB(WHITE_FONT_COLOR);
end

local function BackpackTokenFrame_UpdateHook()
	local noCurrencyShown = true;
	for i=1, MAX_WATCHED_TOKENS do
		local watchButton = _G["BackpackTokenFrameToken"..i];

		local currencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo(i);
		if currencyInfo then
			local quantity, currencyID = currencyInfo["quantity"], currencyInfo["currencyTypesID"]
			local maximum = C_CurrencyInfo.GetCurrencyInfo(currencyID)["maxQuantity"];

			-- Custom coloring for capped currencies
			watchButton.count:SetTextColor(ColorCount(quantity, maximum));

			-- Enhanced formatting
			watchButton.count:SetText(FormatCount(quantity));

			noCurrencyShown = false
		end
	end
	if noCurrencyShown then
		BackpackTokenFrame:Hide();
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
		
		-- Hook the rendering of the currency buttons to enable custom rendering of currency amount
		hooksecurefunc("BackpackTokenFrame_Update", BackpackTokenFrame_UpdateHook);
	end
end		

-- Bootstrap
local BCE_Frame = CreateFrame("Frame", "BCE_Frame", UIParent);
BCE_Frame:SetScript("OnEvent", Init);
BCE_Frame:RegisterEvent("ADDON_LOADED");
