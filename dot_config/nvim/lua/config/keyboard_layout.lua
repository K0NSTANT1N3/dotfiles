local M = {}

-- langmap translates the characters produced by the active typing layout into
-- the commands found at the same physical positions on a QWERTY keyboard.
local function escape_langmap(value)
  return value
    :gsub("\\", "\\\\")
    :gsub(";", "\\;")
    :gsub(",", "\\,")
    :gsub('"', '\\"')
    :gsub("|", "\\|")
end

local function make_profile(from, to)
  assert(
    vim.fn.strchars(from) == vim.fn.strchars(to),
    "langmap sides must contain the same number of characters"
  )

  local translation = {}
  for index = 0, vim.fn.strchars(from) - 1 do
    local source = vim.fn.strcharpart(from, index, 1)
    local target = vim.fn.strcharpart(to, index, 1)
    translation[source] = target
  end

  return {
    langmap = escape_langmap(from) .. ";" .. escape_langmap(to),
    translation = translation,
  }
end

local qwerty_lower = "qwertyuiopasdfghjkl;zxcvbnm,./"
local qwerty_upper = "QWERTYUIOPASDFGHJKL:ZXCVBNM<>?"

local profiles = {
  qwerty = { langmap = "", translation = {} },
  colemak = make_profile(
    "qwfpgjluy;arstdhneiozxcvbkm,./" .. "QWFPGJLUY:ARSTDHNEIOZXCVBKM<>?",
    qwerty_lower .. qwerty_upper
  ),
  georgian = make_profile(
    "ქწერტყუიოპასდფგჰჯკლ;ზხცვბნმ,./" .. "QჭEღთYUIOPAშDFGHჟKL:ძXჩVBNM<>?",
    qwerty_lower .. qwerty_upper
  ),
}

local active_translation = {}
local automatic = true
local event_poll
local display
local x11
local xkb_state
local xevent
local layouts = {}
local variants = {}
local last_group = -1

local function apply(profile, notify)
  local selected = profiles[profile]
  if not selected then
    return
  end

  vim.opt.langmap = selected.langmap
  vim.opt.langremap = false
  active_translation = selected.translation

  if notify then
    vim.notify("Keyboard profile: " .. profile)
  end
end

-- Some plugins (notably which-key) read pending keys with getcharstr(), which
-- bypasses 'langmap'. They can use this function at that one input boundary.
function M.translate_key(key, mode)
  if mode and not mode:match("^[novVs\22]") then
    return key
  end
  return active_translation[key] or key
end

local function split_xkb_list(value)
  if not value then
    return {}
  end
  return vim.split(vim.trim(value), ",", { plain = true, trimempty = false })
end

local function read_xkb_configuration()
  if vim.fn.executable("setxkbmap") ~= 1 or not vim.env.DISPLAY then
    return false
  end

  local output = vim.fn.systemlist({ "setxkbmap", "-query" })
  if vim.v.shell_error ~= 0 then
    return false
  end

  local values = {}
  for _, line in ipairs(output) do
    local key, value = line:match("^%s*([^:]+):%s*(.-)%s*$")
    if key then
      values[key] = value
    end
  end

  layouts = split_xkb_list(values.layout)
  variants = split_xkb_list(values.variant)
  return #layouts > 0
end

local function profile_for_group(group)
  local layout = (layouts[group + 1] or ""):lower()
  local variant = (variants[group + 1] or ""):lower()

  if layout == "ge" then
    return "georgian"
  end
  if layout == "us" and variant:find("colemak", 1, true) then
    return "colemak"
  end

  -- Plain US and unknown layouts are left untranslated.
  return "qwerty"
end

local function open_x11()
  local ok, ffi = pcall(require, "ffi")
  if not ok or not vim.env.DISPLAY then
    return false
  end

  pcall(ffi.cdef, [[
    typedef struct _XDisplay Display;
    typedef struct {
      unsigned char group;
      unsigned char locked_group;
      unsigned short base_group;
      unsigned short latched_group;
      unsigned char mods;
      unsigned char base_mods;
      unsigned char latched_mods;
      unsigned char locked_mods;
      unsigned char compat_state;
      unsigned char grab_mods;
      unsigned char compat_grab_mods;
      unsigned char lookup_mods;
      unsigned char compat_lookup_mods;
      unsigned short ptr_buttons;
    } XkbStateRec;
    typedef union {
      int type;
      long pad[24];
    } XEvent;
    Display *XOpenDisplay(const char *display_name);
    int XCloseDisplay(Display *display);
    int XConnectionNumber(Display *display);
    int XFlush(Display *display);
    int XPending(Display *display);
    int XNextEvent(Display *display, XEvent *event_return);
    int XkbQueryExtension(Display *display, int *opcode, int *event_base,
                          int *error_base, int *major, int *minor);
    int XkbSelectEvents(Display *display, unsigned int device_spec,
                        unsigned int affect, unsigned int values);
    int XkbSelectEventDetails(Display *display, unsigned int device_spec,
                              unsigned int event_type, unsigned long affect,
                              unsigned long details);
    int XkbGetState(Display *display, unsigned int device_spec, XkbStateRec *state);
  ]])

  local loaded, library = pcall(ffi.load, "X11")
  if not loaded then
    return false
  end

  local opened = library.XOpenDisplay(nil)
  if opened == nil then
    return false
  end

  x11 = library
  display = opened
  xkb_state = ffi.new("XkbStateRec[1]")
  xevent = ffi.new("XEvent[1]")

  local opcode = ffi.new("int[1]")
  local event_base = ffi.new("int[1]")
  local error_base = ffi.new("int[1]")
  local major = ffi.new("int[1]", 1)
  local minor = ffi.new("int[1]", 0)
  if x11.XkbQueryExtension(display, opcode, event_base, error_base, major, minor) == 0 then
    x11.XCloseDisplay(display)
    display = nil
    return false
  end

  -- Subscribe only to XkbStateNotify. It is emitted when the active group
  -- changes, so Neovim sleeps instead of repeatedly checking the layout.
  local state_notify_mask = 0x04
  if x11.XkbSelectEvents(display, 0x0100, state_notify_mask, state_notify_mask) == 0 then
    x11.XCloseDisplay(display)
    display = nil
    return false
  end
  local all_state_components = 0x3fff
  local group_state_components = 0x00f0
  if
    x11.XkbSelectEventDetails(display, 0x0100, 2, all_state_components, group_state_components) == 0
  then
    x11.XCloseDisplay(display)
    display = nil
    return false
  end
  x11.XFlush(display)
  return true
end

local function poll_layout()
  if not automatic or not display then
    return
  end

  -- XkbUseCoreKbd = 0x0100; XkbGetState returns 0 on success.
  if x11.XkbGetState(display, 0x0100, xkb_state) ~= 0 then
    return
  end

  local group = tonumber(xkb_state[0].group)
  if group == last_group then
    return
  end
  last_group = group

  vim.schedule(function()
    if automatic then
      apply(profile_for_group(group), false)
    end
  end)
end

local function enable_automatic_detection(notify)
  automatic = true
  last_group = -1
  read_xkb_configuration()
  poll_layout()
  if notify then
    vim.notify("Keyboard profile: automatic")
  end
end

local function process_x11_events()
  if not display then
    return
  end

  while x11.XPending(display) > 0 do
    x11.XNextEvent(display, xevent)
  end
  poll_layout()
end

function M.setup()
  -- Sensible fallback when X11 detection is unavailable (SSH, Wayland, etc.).
  apply("colemak", false)

  vim.api.nvim_create_user_command("KeyboardLayoutAuto", function()
    enable_automatic_detection(true)
  end, { desc = "Follow the active XKB keyboard layout" })

  for _, profile in ipairs({ "qwerty", "colemak", "georgian" }) do
    local command = "KeyboardLayout" .. profile:sub(1, 1):upper() .. profile:sub(2)
    vim.api.nvim_create_user_command(command, function()
      automatic = false
      apply(profile, true)
    end, { desc = "Use the " .. profile .. " keyboard profile" })
  end

  if read_xkb_configuration() and open_x11() then
    local uv = vim.uv or vim.loop
    event_poll = uv.new_poll(x11.XConnectionNumber(display))
    event_poll:start("r", vim.schedule_wrap(process_x11_events))
    poll_layout()
  end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if event_poll then
        event_poll:stop()
        event_poll:close()
        event_poll = nil
      end
      if display then
        x11.XCloseDisplay(display)
        display = nil
      end
    end,
  })
end

return M
