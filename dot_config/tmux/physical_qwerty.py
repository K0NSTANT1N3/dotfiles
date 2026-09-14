#!/usr/bin/env python3
"""Keep every tmux binding on its physical QWERTY key under XKB layouts."""

from __future__ import annotations

import ctypes
import fcntl
import hashlib
import os
import re
import select
import signal
import subprocess
import sys
import time
from collections import defaultdict


QWERTY_LOWER = "qwertyuiopasdfghjkl;zxcvbnm,./"
QWERTY_UPPER = "QWERTYUIOPASDFGHJKL:ZXCVBNM<>?"

PROFILE_OUTPUT = {
    "qwerty": QWERTY_LOWER + QWERTY_UPPER,
    "colemak": (
        "qwfpgjluy;arstdhneiozxcvbkm,./"
        "QWFPGJLUY:ARSTDHNEIOZXCVBKM<>?"
    ),
    "georgian": (
        "ქწერტყუიოპასდფგჰჯკლ;ზხცვბნმ,./"
        "QჭEღთYUIOPAშDFGHჟKL:ძXჩVBNM<>?"
    ),
}

QWERTY_KEYS = QWERTY_LOWER + QWERTY_UPPER
KEY_MAPS = {
    profile: dict(zip(QWERTY_KEYS, output, strict=True))
    for profile, output in PROFILE_OUTPUT.items()
}

# Georgian changes the key left of 1 as well. Other non-letter keys are in the
# same physical positions in the three configured layouts.
KEY_MAPS["georgian"].update({"`": "„", "~": "“"})

CANONICAL_PREFIX = "__physical_qwerty_"
TABLES_OPTION = "@physical-qwerty-tables"
PREFIX_OPTION = "@physical-qwerty-prefix"
PREFIX2_OPTION = "@physical-qwerty-prefix2"
PROFILE_OPTION = "@physical-qwerty-layout"
BINDING_RE = re.compile(r"^(bind-key\s+.*?-T\s+)(\S+)(\s+)(\S+)(\s+.*)$")
MODIFIER_RE = re.compile(r"^((?:(?:C|M|S)-)+)(.+)$")


class Tmux:
    def __init__(self, socket_path: str) -> None:
        self.command = ["tmux", "-S", socket_path]

    def run(
        self,
        *args: str,
        input_text: str | None = None,
        check: bool = True,
    ) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(
            [*self.command, *args],
            input=input_text,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if check and result.returncode != 0:
            command = " ".join([*self.command, *args])
            raise RuntimeError(f"{command} failed: {result.stderr.strip()}")
        return result

    def output(self, *args: str) -> str:
        return self.run(*args).stdout

    def option(self, name: str) -> str:
        return self.output("show-options", "-gqv", name).strip()

    def source(self, commands: list[str]) -> None:
        if commands:
            self.run("source-file", "-", input_text="\n".join(commands) + "\n")

    def alive(self) -> bool:
        return self.run("display-message", "-p", "#{pid}", check=False).returncode == 0


def canonical_table(table: str) -> str:
    return CANONICAL_PREFIX + re.sub(r"[^A-Za-z0-9_.-]", "_", table)


def parse_binding(line: str) -> re.Match[str]:
    match = BINDING_RE.match(line)
    if not match:
        raise RuntimeError(f"cannot parse tmux binding: {line}")
    return match


def replace_binding(line: str, table: str, key: str) -> str:
    match = parse_binding(line)
    return f"{match[1]}{table}{match[3]}{key}{match[5]}"


def decode_key(value: str) -> str:
    if len(value) == 2 and value.startswith("\\"):
        return value[1]
    return value


def encode_key(value: str) -> str:
    if value in "\\;,#$%\"'|{}":
        return "\\" + value
    return value


def translate_key(key: str, profile: str) -> str:
    modifiers = ""
    base = key
    match = MODIFIER_RE.match(key)
    if match:
        modifiers, base = match.groups()

    character = decode_key(base)
    if len(character) != 1:
        return key

    translated = KEY_MAPS[profile].get(character, character)
    if translated == character:
        return key
    return modifiers + encode_key(translated)


def list_tables(tmux: Tmux) -> dict[str, list[str]]:
    tables: dict[str, list[str]] = defaultdict(list)
    for line in tmux.output("list-keys", "-a").splitlines():
        match = parse_binding(line)
        table = match[2]
        if not table.startswith(CANONICAL_PREFIX):
            tables[table].append(line)
    return dict(tables)


def create_canonical_tables(tmux: Tmux) -> list[str]:
    tables = list_tables(tmux)
    commands: list[str] = []

    for table, bindings in tables.items():
        saved_table = canonical_table(table)
        commands.append(f"unbind-key -aq -T {saved_table}")
        for line in bindings:
            match = parse_binding(line)
            commands.append(replace_binding(line, saved_table, match[4]))

    prefix = tmux.option("prefix")
    prefix2 = tmux.option("prefix2")
    commands.extend(
        [
            f"set-option -g {TABLES_OPTION} '{','.join(tables)}'",
            f"set-option -g {PREFIX_OPTION} '{prefix}'",
            f"set-option -g {PREFIX2_OPTION} '{prefix2}'",
        ]
    )
    tmux.source(commands)
    return list(tables)


def canonical_tables(tmux: Tmux) -> list[str]:
    value = tmux.option(TABLES_OPTION)
    if not value:
        return create_canonical_tables(tmux)
    return value.split(",")


def apply_profile(tmux: Tmux, profile: str) -> None:
    tables = canonical_tables(tmux)
    commands: list[str] = []

    for table in tables:
        commands.append(f"unbind-key -a -T {table}")
        saved_table = canonical_table(table)
        for line in tmux.output("list-keys", "-T", saved_table).splitlines():
            match = parse_binding(line)
            key = translate_key(match[4], profile)
            commands.append(replace_binding(line, table, key))

    prefix = tmux.option(PREFIX_OPTION)
    prefix2 = tmux.option(PREFIX2_OPTION)
    if prefix:
        commands.append(f"set-option -g prefix {translate_key(prefix, profile)}")
    if prefix2:
        commands.append(f"set-option -g prefix2 {translate_key(prefix2, profile)}")
    else:
        commands.append("set-option -gu prefix2")
    commands.append(f"set-option -g {PROFILE_OPTION} {profile}")
    tmux.source(commands)


def watcher_lock_path(socket_path: str) -> str:
    digest = hashlib.sha256(socket_path.encode()).hexdigest()[:16]
    return f"/tmp/tmux-physical-qwerty-{os.getuid()}-{digest}.lock"


def stop_watcher(socket_path: str) -> None:
    try:
        with open(watcher_lock_path(socket_path), encoding="utf-8") as lock_file:
            pid = int(lock_file.read().strip())
        if pid != os.getpid():
            os.kill(pid, signal.SIGTERM)
    except (FileNotFoundError, ProcessLookupError, PermissionError, ValueError):
        pass


def disable(socket_path: str) -> None:
    stop_watcher(socket_path)
    tmux = Tmux(socket_path)
    if tmux.option(TABLES_OPTION):
        apply_profile(tmux, "qwerty")
    tmux.run("set-option", "-g", PROFILE_OPTION, "disabled")


def read_xkb_profiles() -> list[str]:
    result = subprocess.run(
        ["setxkbmap", "-query"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    values: dict[str, str] = {}
    for line in result.stdout.splitlines():
        key, separator, value = line.partition(":")
        if separator:
            values[key.strip()] = value.strip()

    layouts = values.get("layout", "").split(",")
    variants = values.get("variant", "").split(",")
    variants.extend([""] * (len(layouts) - len(variants)))

    profiles = []
    for layout, variant in zip(layouts, variants):
        if layout == "ge":
            profiles.append("georgian")
        elif layout == "us" and "colemak" in variant:
            profiles.append("colemak")
        else:
            profiles.append("qwerty")
    return profiles


class XkbState(ctypes.Structure):
    _fields_ = [
        ("group", ctypes.c_ubyte),
        ("locked_group", ctypes.c_ubyte),
        ("base_group", ctypes.c_ushort),
        ("latched_group", ctypes.c_ushort),
        ("mods", ctypes.c_ubyte),
        ("base_mods", ctypes.c_ubyte),
        ("latched_mods", ctypes.c_ubyte),
        ("locked_mods", ctypes.c_ubyte),
        ("compat_state", ctypes.c_ubyte),
        ("grab_mods", ctypes.c_ubyte),
        ("compat_grab_mods", ctypes.c_ubyte),
        ("lookup_mods", ctypes.c_ubyte),
        ("compat_lookup_mods", ctypes.c_ubyte),
        ("ptr_buttons", ctypes.c_ushort),
    ]


class XEvent(ctypes.Union):
    _fields_ = [("type", ctypes.c_int), ("padding", ctypes.c_long * 24)]


class Xkb:
    CORE_KEYBOARD = 0x0100
    STATE_NOTIFY = 2
    STATE_NOTIFY_MASK = 0x04
    ALL_STATE_COMPONENTS = 0x3FFF
    GROUP_STATE_COMPONENTS = 0x00F0

    def __init__(self) -> None:
        self.x11 = ctypes.CDLL("libX11.so.6")
        self._declare_functions()
        self.display = self.x11.XOpenDisplay(None)
        if not self.display:
            raise RuntimeError("cannot open the X11 display")

        opcode = ctypes.c_int()
        event_base = ctypes.c_int()
        error_base = ctypes.c_int()
        major = ctypes.c_int(1)
        minor = ctypes.c_int(0)
        if not self.x11.XkbQueryExtension(
            self.display,
            ctypes.byref(opcode),
            ctypes.byref(event_base),
            ctypes.byref(error_base),
            ctypes.byref(major),
            ctypes.byref(minor),
        ):
            raise RuntimeError("the XKB extension is unavailable")

        if not self.x11.XkbSelectEvents(
            self.display,
            self.CORE_KEYBOARD,
            self.STATE_NOTIFY_MASK,
            self.STATE_NOTIFY_MASK,
        ):
            raise RuntimeError("cannot subscribe to XKB state events")
        if not self.x11.XkbSelectEventDetails(
            self.display,
            self.CORE_KEYBOARD,
            self.STATE_NOTIFY,
            self.ALL_STATE_COMPONENTS,
            self.GROUP_STATE_COMPONENTS,
        ):
            raise RuntimeError("cannot select XKB group-change events")
        self.x11.XFlush(self.display)

    def _declare_functions(self) -> None:
        self.x11.XOpenDisplay.argtypes = [ctypes.c_char_p]
        self.x11.XOpenDisplay.restype = ctypes.c_void_p
        self.x11.XCloseDisplay.argtypes = [ctypes.c_void_p]
        self.x11.XConnectionNumber.argtypes = [ctypes.c_void_p]
        self.x11.XConnectionNumber.restype = ctypes.c_int
        self.x11.XFlush.argtypes = [ctypes.c_void_p]
        self.x11.XPending.argtypes = [ctypes.c_void_p]
        self.x11.XPending.restype = ctypes.c_int
        self.x11.XNextEvent.argtypes = [ctypes.c_void_p, ctypes.POINTER(XEvent)]
        self.x11.XkbQueryExtension.argtypes = [
            ctypes.c_void_p,
            ctypes.POINTER(ctypes.c_int),
            ctypes.POINTER(ctypes.c_int),
            ctypes.POINTER(ctypes.c_int),
            ctypes.POINTER(ctypes.c_int),
            ctypes.POINTER(ctypes.c_int),
        ]
        self.x11.XkbQueryExtension.restype = ctypes.c_int
        self.x11.XkbSelectEvents.argtypes = [
            ctypes.c_void_p,
            ctypes.c_uint,
            ctypes.c_uint,
            ctypes.c_uint,
        ]
        self.x11.XkbSelectEvents.restype = ctypes.c_int
        self.x11.XkbSelectEventDetails.argtypes = [
            ctypes.c_void_p,
            ctypes.c_uint,
            ctypes.c_uint,
            ctypes.c_ulong,
            ctypes.c_ulong,
        ]
        self.x11.XkbSelectEventDetails.restype = ctypes.c_int
        self.x11.XkbGetState.argtypes = [
            ctypes.c_void_p,
            ctypes.c_uint,
            ctypes.POINTER(XkbState),
        ]
        self.x11.XkbGetState.restype = ctypes.c_int

    def group(self) -> int:
        state = XkbState()
        if self.x11.XkbGetState(
            self.display, self.CORE_KEYBOARD, ctypes.byref(state)
        ) != 0:
            raise RuntimeError("cannot read the active XKB group")
        return state.group

    def fileno(self) -> int:
        return self.x11.XConnectionNumber(self.display)

    def drain_events(self) -> None:
        event = XEvent()
        while self.x11.XPending(self.display):
            self.x11.XNextEvent(self.display, ctypes.byref(event))

    def close(self) -> None:
        if self.display:
            self.x11.XCloseDisplay(self.display)
            self.display = None


def wait_for_plugins(tmux: Tmux) -> None:
    time.sleep(1)
    deadline = time.monotonic() + 30
    while (
        tmux.option("@__apply_plugins") == "true"
        and time.monotonic() < deadline
    ):
        time.sleep(0.2)
    time.sleep(0.2)


def acquire_watcher_lock(socket_path: str) -> int | None:
    path = watcher_lock_path(socket_path)
    descriptor = os.open(path, os.O_CREAT | os.O_RDWR, 0o600)
    try:
        fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        try:
            pid = int(os.read(descriptor, 32).decode().strip())
            os.kill(pid, signal.SIGUSR1)
        except (OSError, ValueError):
            pass
        os.close(descriptor)
        return None

    os.ftruncate(descriptor, 0)
    os.write(descriptor, str(os.getpid()).encode())
    return descriptor


def watch(socket_path: str) -> None:
    lock = acquire_watcher_lock(socket_path)
    if lock is None:
        return

    tmux = Tmux(socket_path)
    wait_for_plugins(tmux)
    profiles = read_xkb_profiles()
    xkb = Xkb()

    wake_read, wake_write = os.pipe2(os.O_NONBLOCK | os.O_CLOEXEC)
    refresh_requested = False

    def request_refresh(_signum: int, _frame: object) -> None:
        nonlocal refresh_requested
        refresh_requested = True

    signal.signal(signal.SIGUSR1, request_refresh)
    signal.set_wakeup_fd(wake_write)

    last_group = -1
    try:
        while tmux.alive():
            group = xkb.group()
            if group != last_group:
                profile = profiles[group] if group < len(profiles) else "qwerty"
                apply_profile(tmux, profile)
                last_group = group

            readable, _, _ = select.select([xkb.fileno(), wake_read], [], [], 60)
            if xkb.fileno() in readable:
                xkb.drain_events()
            if wake_read in readable:
                try:
                    os.read(wake_read, 4096)
                except BlockingIOError:
                    pass
            if refresh_requested:
                refresh_requested = False
                wait_for_plugins(tmux)
                last_group = -1
    finally:
        signal.set_wakeup_fd(-1)
        os.close(wake_read)
        os.close(wake_write)
        xkb.close()
        os.close(lock)


def main() -> None:
    if len(sys.argv) == 3 and sys.argv[1] == "--disable":
        disable(sys.argv[2])
        return
    if len(sys.argv) == 4 and sys.argv[1] == "--apply-once":
        apply_profile(Tmux(sys.argv[2]), sys.argv[3])
        return
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {sys.argv[0]} TMUX_SOCKET")
    watch(sys.argv[1])


if __name__ == "__main__":
    main()
