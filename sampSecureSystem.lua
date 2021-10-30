require "lib.moonloader"

local id = -1
local keys = require "vkeys"
local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local encoding = require 'encoding'


encoding.default = 'CP1251'
u8 = encoding.UTF8

local main_window_state = imgui.ImBool(false)
local protocol_window_state = imgui.ImBool(false)
local window_overlay = imgui.ImBool(false)

local inicfg = require 'inicfg'

local directIni = "sampsecure.ini"
local ini = inicfg.load(inicfg.load({
      savename = {
        name = 'Нету',
  },
      antidm = {
        playerId = "N/A",
        damage = "N/A",
    },   
}, directIni))
inicfg.save(ini, directIni)

local mainIni = inicfg.load(nil, directIni)

local color_red = 0xFF0000
local color_blue = 0x1E90FF
local tag = "{1E90FF}[SECURE{FF0000}{1E90FF}SYSTEM]"

local fa = require 'faIcons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

local script_version = "RELASE-1.0"
-------------------------------------

local text_info_secure = [[SecureSystem - Это скрипт для защиты вас в сампе.
У нас есть система протоколов, меню протколов активируется на кнопку K
Узнать подробнее о протоколах можно в вкладке "Протоколы".
Узнать о остальных командах можно в влкдаке "Команды"
Приятной и безопасной вам игры.
]]

local protocol_system_text = [[Меню протоколов активируется через кнопку K
Протоколы такого вида /pt7 активируются только через команду!
Номера протоколов. 

P:Anti-DM - Защита от стандартного ДМ-а, надевает вам бронежилет и маску. 
P:Anti-Cheat - Сообщяет о читере в репорт.
/pt7 ID  - Режим сделки. 
P:Anti-DB - Защита от ДБ.
Жалоба DM - Отпровляет жалобу с ID последнего напавшего.
]]

local command_info_text = [[/soverlay - Оверлей, выводит информацию о нападающем.
/getnamess - Получить сохаренный ник.
/setnamess - Сохранить ник.

]]

local instruction_text_s = [[Здесь информация как не попасться на развод или обман.
Вся информация исключительно в ознакомительных целях!

Случай #1 
Развод на цр с помощью "раздачи" в лавке.
Если какой-то человек, зовет вас в лавку и якобы говорит, что будет сливать
Дорогие аксы и вещи, например из-а того, что уходит с сервера, не верте!
Сообщите об этом в репорт, это способ развода, когда он ставит за маленькие цены
Вещи, а потом дешёвую вещь за очень много денег. 
В будущем возможно мы добавим от этого систему защиты.

Случай #2
Когда вы находитесь на авто базаре или центральном рынке при покупке вам могут подкинуть трейд.
Например вы хотите купить машину, и стоите рядом с владельцом, вы с ним договорились о том, что
Он кидает вам трейд, вы ему евро он вам машину, но тут под землей может сидеть читер-разводила,
Который может вам подкинуть трейд и вы ему отдадите деньги, по этому всегда проверяйте ники кому передаёте деньги.

И Самое главное, всегда проверяйте ники, суммы которые передаете так шанс, что вас разведут уменьшится.
]]
----------------------------------------


function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
    
    print(tag .. "  LOAD. VERSION {FF0000} " .. script_version)
    print(tag .. "  {FFFFFF}Сервера которые поддерживаются скриптом: {FF0000} Arizona Rp.")

    sampAddChatMessage(tag .." {FFFFFF}Загружен. Меню с командами и информацией /secureS. Скрипт в версии " ..script_version, -1)
    -- protocol
    sampRegisterChatCommand("pt7", cmd_pt7)
    -- other
    sampRegisterChatCommand("setnamess", cmd_setnamess)
    sampRegisterChatCommand("getnamess", cmd_getnamess)
    sampRegisterChatCommand("jb", cmd_jb)
    sampRegisterChatCommand("secures", function() main_window_state.v = not main_window_state.v end)
    sampRegisterChatCommand("soverlay", function() window_overlay.v = not window_overlay.v imgui.ShowCursor = false end)

    while true do
		wait(0)


        imgui.Process = main_window_state.v or protocol_window_state.v or window_overlay.v

        if isKeyJustPressed(VK_K) and not sampIsChatInputActive() then 
            protocol_window_state.v = not protocol_window_state.v
        end

        if main_window_state.v or protocol_window_state.v then -- окна с курсорам
            imgui.ShowCursor = true
        else -- Окна без курсора или нет активных окон
            imgui.ShowCursor = false
        end

        local _, myid = sampGetPlayerIdByCharHandle(playerPed)
        mynick = sampGetPlayerNickname(myid)

    end

end
-- other

function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
    if playerId ~= 65535 then
        damage = ("%.0f"):format(damage)
        mainIni.antidm.playerId = playerId
        mainIni.antidm.damage = damage 
    end
    if inicfg.save(mainIni, directIni) then
    end
end


function cmd_jb()
    lua_thread.create(function()
        sampAddChatMessage(tag .. "{FFFFFF} Успешно отправил жалобу!")
            wait(1)
        sampSendChat('/report')
            wait(1)
        sampSendDialogResponse(32, -1, -1, "Помогите, меня ДМ-ит игрок")
            wait(150)
        sampCloseCurrentDialogWithButton(0)
    end)
end

function cmd_getnamess(arg)
    mainIni = inicfg.load(nil, directIni)
    sampAddChatMessage(tag .. "{FFFFFF} Cохраненый ник: " .. mainIni.savename.name .. ".", -1)
end

function cmd_setnamess(arg)
    mainIni.savename.name = arg 
    if inicfg.save(mainIni, directIni) then
      sampAddChatMessage(tag .. "{FFFFFF} Ник успешно сохранён!", -1)
    end
end

-- PROTOCOL COMMAND --

function cmd_pt7(id)
   if id:match("%d") then
    lua_thread.create(function()
        
        sampAddChatMessage(tag .. "{FF0000} Включен режим сделки. Начинаю выполнять протокол.")
        sampAddChatMessage(tag .. "{FFFFFF} Проверь включил ли ты фрапс.")
        sampSendChat("/id " ..id)
            wait(1500)
        sampSendChat("/time")
        sampAddChatMessage(tag .. "{FFFFFF} Чтобы сохранить ник введите /setnamess и ник. Чтобы просмотреть /getnamess")
     end)
    else 
        sampAddChatMessage(tag .. "{FF0000} Ошибка | Введите ID")
    end
end

-- imgui --
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/sampsecure/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
    end
end

function imgui.OnDrawFrame()

if main_window_state.v then 
    local sizeX, sizeY = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) -- Расположение
    imgui.SetNextWindowSize(imgui.ImVec2(700, 500), imgui.Cond.FirstUseEver) -- Размеры
    imgui.Begin(fa.ICON_COGS .. u8" Главное меню SampSecureSystem v. " .. script_version, main_window_state)

    imgui.SameLine()

    imgui.BeginChild('child2', imgui.ImVec2(130, 249), true)

    if imgui.Button(fa.ICON_INFO_CIRCLE .. u8" Информация", imgui.ImVec2(100, 50)) then
        textinfo = not textinfo
    end

    if imgui.Button(fa.ICON_ID_CARD .. u8" Протоколы", imgui.ImVec2(100, 50)) then
        protection_text = not protection_text
     end

    if imgui.Button(fa.ICON_TERMINAL .. u8" Команды", imgui.ImVec2(100, 50)) then
        command_text = not command_text
     end

     if imgui.Button(fa.ICON_FILE_TEXT_O .. u8" Руководства", imgui.ImVec2(100, 50)) then
        instruction_text = not instruction_text
     end

    imgui.EndChild()

    imgui.SameLine()
    imgui.BeginChild('child3', imgui.ImVec2(-1,-1), true)

    if textinfo then
        imgui.Text(u8(text_info_secure))

        if imgui.Button(fa.ICON_SITEMAP .. u8" Тема на BlastHack") then
            os.execute('explorer "https://www.blast.hk/threads/105676/"')
        end

        imgui.SameLine()
        if imgui.Button(fa.ICON_PAPER_PLANE .. u8" Тех.Поддержка") then
            os.execute('explorer "https://vk.com/im?sel=-208243482"')
        end

        imgui.SameLine()
        if imgui.Button(fa.ICON_VK .. u8" Группа ВК") then
            os.execute('explorer "https://vk.com/securesa"')
        end

        imgui.Text(u8"Сохраненные ники: ".. mainIni.savename.name)

    end

    if protection_text then
        imgui.Text(u8(protocol_system_text))
    end

    if command_text then
        imgui.Text(u8(command_info_text))
    end

    if instruction_text then
        imgui.Text(u8(instruction_text_s))
    end

    imgui.EndChild()

    imgui.End()
    end

    if protocol_window_state.v then
        local sizeX, sizeY = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) -- Расположение
        imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver) -- Размеры
        imgui.Begin(fa.ICON_GAVEL .. u8" Протоколы", protocol_window_state)

        if imgui.Button(u8"P:Anti-DM", imgui.ImVec2(80, 30)) then
            lua_thread.create(function()

                sampAddChatMessage(tag .. "{FFFFFF} Протокол 13 активирован! Начинаю защиту...")
                wait(100)
                sampSendChat("/armour")
                wait(3500)
                sampSendChat("/mask")

            end)
        end

        imgui.SameLine()

        if imgui.Button(u8"P:Anti-Cheat", imgui.ImVec2(80, 30)) then
            lua_thread.create(function()

                sampAddChatMessage(tag .. "{FFFFFF} Протокол Anti-Cheat активирован! Чтобы защититься от читера, можете выйти в AFK, кнопка ESC.")
                sampSendChat('/report')
                    wait(1)
                sampSendDialogResponse(32, -1, -1, "Помогите, тут читер! ")
                    wait(150)
                sampCloseCurrentDialogWithButton(0)

            end)
        end

        imgui.SameLine()

        if imgui.Button(u8"P:Anti-DB", imgui.ImVec2(80, 30)) then
            lua_thread.create(function()

                sampAddChatMessage(tag .. "{FFFFFF} Протокол Anti-DB активирован!")
                sampSendChat('/report')
                    wait(1)
                sampSendDialogResponse(32, -1, -1, "Помогите, меня ДБшат!! ")
                    wait(150)
                sampCloseCurrentDialogWithButton(0)
                    wait(1500)
                sampSendChat("/usemed")

            end)
        end

        if imgui.Button(u8"Жалоба DM", imgui.ImVec2(80, 30)) then  
            lua_thread.create(function()
                sampAddChatMessage(tag .. "{FFFFFF} Успешно отправил жалобу!")
                    wait(1)
                sampSendChat('/report')
                    wait(1)
                sampSendDialogResponse(32, -1, -1, "Помогите, меня ДМ-ит игрок c ID " .. mainIni.antidm.playerId)
                    wait(150)
                sampCloseCurrentDialogWithButton(0)
            end)
        end 

        imgui.End()
    end

    if window_overlay.v then
        mainIni = inicfg.load(nil, directIni)
        local unix_time = os.time(os.date('!*t'))
        local moscow_time = unix_time + 3 * 60 * 60
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED) 
        local ping = sampGetPlayerPing(myid)
        local nick = sampGetPlayerNickname(myid)
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(sw/1.1,sh/1.5),imgui.Cond.Always,imgui.ImVec2(0.5,0.5))
        imgui.Begin("##SecureOverlay", window_overlay.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
       
        imgui.Text(fa.ICON_SERVER .. " SecureOverlay")
        imgui.Text(fa.ICON_ID_CARD_O .. u8" ID игрока " .. mainIni.antidm.playerId)
        imgui.Text(u8"Количество урона " .. mainIni.antidm.damage .. " HP")
        imgui.End()
    end


end


-- theme 
function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
 
     style.WindowPadding = ImVec2(15, 15)
     style.WindowRounding = 15.0
     style.FramePadding = ImVec2(5, 5)
     style.ItemSpacing = ImVec2(12, 8)
     style.ItemInnerSpacing = ImVec2(8, 6)
     style.IndentSpacing = 25.0
     style.ScrollbarSize = 15.0
     style.ScrollbarRounding = 15.0
     style.GrabMinSize = 15.0
     style.GrabRounding = 7.0
     style.ChildWindowRounding = 8.0
     style.FrameRounding = 6.0
   
 
       colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
       colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
       colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
       colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
       colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
       colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
       colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
       colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
       colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
       colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
       colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
       colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
       colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
       colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
       colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
       colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
       colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
       colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
       colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
       colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
       colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
       colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
       colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
       colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
       colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
       colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
       colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
       colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
       colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
       colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
       colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
       colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
       colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
       colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
 end
 apply_custom_style()
