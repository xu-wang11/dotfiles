local vicious = require("vicious")
local gears = require('gears')
local wibox = require("wibox")
local myutil = require('lib/myutil')
local const = require('rc/const')
local modkey = const.modkey

-- Separators & Icons
local sepopen = wibox.widget.imagebox()
sepopen:set_image(beautiful.my_icons .. "/widgets/left.png")
local sepclose = wibox.widget.imagebox()
sepclose:set_image(beautiful.my_icons .. "/widgets/right.png")
--local spacer = wibox.widget.imagebox()
--spacer:set_image(beautiful.icons .. "/widgets/spacer.png")


local clock_text = wibox.widget.textclock(
  myutil.colored_text("%m-%d %H:%M:%S %a", "#bc5374", 'font_weight="bold"'),
1)
local clock_icon = wibox.widget.imagebox(beautiful.my_icons .. '/widgets/clock.png')
local textclock = wibox.layout.fixed.horizontal()
textclock:add(clock_text)
textclock:add(clock_icon)
textclock:buttons(awful.button({}, 1, function()
    awful.spawn.with_shell(const.browser .. "http://calendar.google.com")
end))

local cpu_widget = wibox.widget.graph()
cpu_widget:set_width(40):set_height(16)
cpu_widget:set_background_color("#00000033")
cpu_widget:set_color({ type = "linear",
                   from = { 0, 0 }, to = { 10,0 },
                   stops = { {0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96" }}})
cpu_widget:buttons(awful.button({}, 1, function()
   myutil.run_term('htop')
end))
vicious.register(cpu_widget, vicious.widgets.cpu, "$1", 7)

local thermal_widget = wibox.widget.textbox()
vicious.register(thermal_widget, vicious.widgets.thermal,
                 function(widget, args)
                     --[[
                        [local t = tonumber(args[1])
                        [return string.format("%d", t).. "℃"
                        ]]
                     local t = myutil.rexec("sensors | grep -Po 'Package.*?C' | awk '{print $NF}' | cut -c 2-3")
                     -- filter out the new line
                     t = t:sub(1,-2) .. '℃'
                     return t
                 end, 19, {"thermal_zone0", "sys"})

local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem,
   myutil.colored_text("$1% ", "#90ee90"), 11)
mem_widget:buttons(awful.button({}, 1, function()
   myutil.run_term('top -o %MEM -d 1', 'top')
end))
local mem_icon = wibox.widget.imagebox(beautiful.my_icons .. '/widgets/mem.png')
local mem_widget_group = wibox.layout.fixed.horizontal()
mem_widget_group:add(mem_icon)
mem_widget_group:add(mem_widget)

--Battery f[[
local bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat, function(widget, args)
				local color = "#990099"
				if args[1] == '+' then color = "#00ffff"
				elseif args[1] == '−' then color = "#1e90ff" end

				local current = args[2]
				if current < 25 and args[1] == '−' then
					if current ~= bat_widget.lastwarn then
						myutil.notify(
                     "Low Battery",
                     "Battery: " .. current .. "%.\n" .. args[3] .. " left.", 'critical')
						bat_widget.lastwarn = current
					end
				end
				return myutil.colored_text(string.format('%s%d%%', args[1], current), color)
			end,
			59, "BAT0")
local bat_icon = wibox.widget.imagebox(beautiful.my_icons .. '/widgets/bat.png')
local bat_widget_group = wibox.layout.fixed.horizontal()
bat_widget_group:add(bat_icon)
bat_widget_group:add(bat_widget)
bat_widget_group:buttons(awful.button({}, 1, function()
   myutil.run_term("sudo powertop", 'powertop')
end))
-- f]]

-- Network f[[
local net_widget = wibox.widget.textbox()
--[[
   [local netgraph = awful.widget.graph()
   [netgraph:set_width(40):set_height(16)
   [netgraph:set_stack(true):set_scale(true)
   [netgraph:set_stack_colors({ "#c2ba62", "#5798d9" })
   [netgraph:set_background_color("#00000033")
   ]]

local net_if
vicious.register(net_widget, vicious.widgets.net, function(widget, args)
        -- TODO update if less frequently
        net_if = myutil.get_active_iface()
        if net_if == nil then
            return myutil.colored_text("No Network", "#5798d9")
        end

        local up, down, iface = 0, 0
        down = down + args[string.format("{%s down_kb}", net_if)] or 0
        up = up + args[string.format("{%s up_kb}", net_if)] or 0
        --[[
           [netgraph:add_value(up, 1)
           [netgraph:add_value(down, 2)
           ]]
        local function format(val)
            if val > 1000000 then return "0" end    -- >1GB, some error, no network
            if val > 500 then return string.format("%.1fM", val/1000.)
            else return string.format("%.0fK", val) end
        end
        -- ↓↑
        return myutil.colored_text(format(down), "#8aa862")
               .. myutil.colored_text(format(up), "#be5160")
    end, 3)
local net_down_icon = wibox.widget.imagebox(beautiful.my_icons .. '/widgets/net_down.png')
local net_up_icon = wibox.widget.imagebox(beautiful.my_icons .. '/widgets/net_up.png')
local net_widget_group = wibox.layout.fixed.horizontal()
net_widget_group:add(net_down_icon)
net_widget_group:add(net_widget)
net_widget_group:add(net_up_icon)
net_widget_group:buttons(awful.button({}, 1, function()
    myutil.run_term(
      'tmux new-session -d "sudo iftop -i "'
      .. net_if .. ' \\; split-window -d "sudo nethogs '
      .. net_if .. '" \\; attach', 'iftop')
end))

-- f]]

--Volume f[[
local volume_widget = wibox.widget.textbox()
local function volumectl(mode)
  -- mode: update, up, down, mute
  function update_cb() volumectl("update") end

  local volume = myutil.trim(myutil.rexec("pamixer --get-volume"))
  if mode == "update" then
     if not tonumber(volume) then
        volume_widget:set_markup(myutil.colored_text('ERR', 'red'))
     else
        awful.spawn.easy_async(
          "pamixer --get-mute",
          function(stdout, ...)
            muted = myutil.trim(stdout)
            if muted == "true" then
               volume = myutil.colored_text('♫M', 'red')
            else
               volume = myutil.colored_text('♫' .. volume, 'green')
            end
            volume_widget:set_markup(volume)
          end)
     end
  elseif mode == "up" then
    volume = tonumber(volume)
    if volume and volume < 120 then
       awful.spawn.easy_async("pamixer --allow-boost --increase 5", update_cb)
    end
  elseif mode == "down" then
     awful.spawn.easy_async("pamixer --allow-boost --decrease 5", update_cb)
  elseif mode == "mute" then
     awful.spawn.easy_async("pamixer --set-volume 20 --toggle-mute", update_cb)
  else
     notify("Unknown volumectl mode: ".. mode)
  end
end
volumectl("update") -- at startup
local volume_clock = gears.timer({ timeout = 60 })
volume_clock:connect_signal("timeout", function() volumectl("update") end)
volume_clock:start()
volume_widget:buttons(gears.table.join(
    awful.button({}, 4, function() volumectl("up") end),
    awful.button({}, 5, function() volumectl("down") end),
    awful.button({}, 3, function() awful.spawn("pavucontrol") end),
    awful.button({}, 1, function() volumectl("mute") end)
))
-- f]]

local btc_widget = wibox.widget.textbox()
local function btcupdate()
  awful.spawn.easy_async_with_shell(
  "curl https://api.coindesk.com/v1/bpi/currentprice.json | jq '.bpi.USD.rate_float' | xargs printf %d",
  function(stdout, stderr, ...)
    local message = "$B: " .. stdout
    message = myutil.colored_text(message, "#cc99ff")
    btc_widget:set_markup(message)
  end)
end

btcupdate()
local btc_clock = gears.timer({ timeout = 300 })
btc_clock:connect_signal("timeout", function() btcupdate() end)
btc_clock:start()


-- tag, task
local TAG_LIST_BUTTONS = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({const.modkey, 'Shift'}, 1, function(t)
      if client.focus then
        client.focus:move_to_tag(t)
      end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({const.modkey, 'Shift'}, 3, function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local task_menu_instance = nil
local TASK_LIST_BUTTONS = gears.table.join(
	  awful.button({}, 1, function(c)
      if task_menu_instance then
        task_menu_instance:hide()
        task_menu_instance = nil
      end
      if c == client.focus and not c.minimized then
          c.minimized = true
      else
          client.focus = c
          c:raise()
      end
    end),
    awful.button({}, 2, function(c) c:kill() end),
    awful.button({}, 3, function()
      if not task_menu_instance then
        task_menu_instance = awful.menu.clients({ width=250 })
      else
        task_menu_instance:hide()
        task_menu_instance = nil
      end
    end),
    awful.button({}, 4, function()
                 awful.client.focus.byidx(1)
                 if client.focus then client.focus:raise() end
             end),
    awful.button({}, 5, function()
                 awful.client.focus.byidx(-1)
                 if client.focus then client.focus:raise() end
             end)
)

local LAYOUT_BOX_BUTTONS = gears.table.join(
    awful.button({}, 1, function() awful.layout.inc(const.available_layouts, 1) end),
    awful.button({}, 3, function() awful.layout.inc(const.available_layouts, -1) end),
    awful.button({}, 4, function() awful.layout.inc(const.available_layouts, 1) end),
    awful.button({}, 5, function() awful.layout.inc(const.available_layouts, -1) end)
)

local systray = wibox.widget.systray()
-- this two lines could fix tray icon background
--systray.forced_width = 140
--systray.opacity = 0
awful.screen.connect_for_each_screen(function(s)
    local layout_box = awful.widget.layoutbox(s.index)
    layout_box:buttons(LAYOUT_BOX_BUTTONS)

    local tag_list = awful.widget.taglist(s, awful.widget.taglist.filter.all, TAG_LIST_BUTTONS)
    local task_list = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, TASK_LIST_BUTTONS)

    s.my_prompt_box = awful.widget.prompt()

    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(layout_box)
    left_layout:add(sepopen)
    left_layout:add(tag_list)
    left_layout:add(sepclose)
    left_layout:add(s.my_prompt_box)

    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(btc_widget)
    right_layout:add(cpu_widget)
    right_layout:add(thermal_widget)
    right_layout:add(mem_widget_group)
    right_layout:add(bat_widget_group)
    -- right_layout:add(netgraph)
    right_layout:add(net_widget_group)

    right_layout:add(volume_widget)

    --[[
       [s.remove_systray = function()
       [  right_layout:remove_widgets(systray)
       [end
       [s.show_systray = function()
       [  local idx = right_layout:index(systray)
       [  if idx == nil then
       [    right_layout:insert(7, systray)
       [  end
       [  systray:set_screen(s)
       [end
       ]]

    if screen:count() == s.index then
      right_layout:add(systray)
      systray:set_screen(s)
    end
    right_layout:add(textclock)

   --right_layout:add(powerline_widget)

    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(task_list)
    layout:set_right(right_layout)

    local bar_height = s.geometry.height * 0.025
    if bar_height > 30 then bar_height = 30 end

    s.my_wibar = awful.wibar({
      position = "top", stretch = true,
      border_width = 0,
      opacity = 0.9,
        ontop = false, screen = s,
      height = bar_height,
      widget = layout
    })
end)

return {volumectl = volumectl}
