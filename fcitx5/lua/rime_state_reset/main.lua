-- 按下输入法切换键或激活 Rime 时，清除其内部保留的英文模式。
local fcitx = require("fcitx")

local function set_rime_to_chinese()
  local succeeded, reason, status = os.execute(
    "/usr/bin/dbus-send --session --type=method_call "
      .. "--dest=org.fcitx.Fcitx5 /rime "
      .. "org.fcitx.Fcitx.Rime1.SetAsciiMode boolean:false"
  )

  if succeeded ~= true then
    fcitx.log(
      string.format(
        "重置 Rime 中文模式失败：%s（状态码：%s）",
        tostring(reason),
        tostring(status)
      )
    )
  end
end

function reset_rime_on_trigger(sym, state, release)
  if sym == 32 and state == fcitx.KeyState.Ctrl and not release then
    set_rime_to_chinese()
  end
  return false
end

function reset_rime_on_activation(input_method)
  if input_method == "rime" then
    set_rime_to_chinese()
  end
end

fcitx.watchEvent(fcitx.EventType.KeyEvent, "reset_rime_on_trigger")
fcitx.watchEvent(fcitx.EventType.InputMethodActivated, "reset_rime_on_activation")
