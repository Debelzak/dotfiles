#!/usr/bin/env python
import hashlib
import os
import contextlib
import json
import dbus
import gi

gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf, GLib
from dbus.mainloop.glib import DBusGMainLoop


def unwrap(value):
    # Try to trivially translate a dictionary's elements into nice string
    # formatting.
    if isinstance(value, dbus.ByteArray):
        return "".join([str(byte) for byte in value])
    if isinstance(value, (dbus.Array, list, tuple)):
        return [unwrap(item) for item in value]
    if isinstance(value, (dbus.Dictionary, dict)):
        return dict([(unwrap(x), unwrap(y)) for x, y in value.items()])
    if isinstance(value, (dbus.Signature, dbus.String)):
        return str(value)
    if isinstance(value, dbus.Boolean):
        return bool(value)
    if isinstance(
        value,
        (dbus.Int16, dbus.UInt16, dbus.Int32, dbus.UInt32, dbus.Int64, dbus.UInt64),
    ):
        return int(value)
    if isinstance(value, dbus.Byte):
        return bytes([int(value)])
    return value


def save_img_byte(px_args):
    image_bytes = b"".join(px_args[6])
    image_hash = hashlib.md5(image_bytes).hexdigest()
    
    # gets image data and saves it to file
    save_path = f"/tmp/notification-{image_hash}.png"

    # return if it already exists
    if os.path.exists(save_path):
        return save_path

    # https://specifications.freedesktop.org/notification-spec/latest/ar01s08.html
    # https://specifications.freedesktop.org/notification-spec/latest/ar01s05.html
    GdkPixbuf.Pixbuf.new_from_bytes(
        width=px_args[0],
        height=px_args[1],
        has_alpha=px_args[3],
        data=GLib.Bytes(px_args[6]),
        colorspace=GdkPixbuf.Colorspace.RGB,
        rowstride=px_args[2],
        bits_per_sample=px_args[4],
    ).savev(save_path, "png")

    return save_path


def message_callback(_, message):
    if type(message) != dbus.lowlevel.MethodCallMessage:
        return
    args_list = message.get_args_list()
    args_list = [unwrap(item) for item in args_list]
    details = {
        "app_name": args_list[0],
        "replace_id": args_list[1],
        "app_icon": args_list[2],
        "summary": args_list[3],
        "body": args_list[4],
        "actions": args_list[5],
        #"hints": args_list[6],
        "expire_timeout": args_list[7],
        "icon_path": None,
    }

    if args_list[2]:
        details["icon_path"] = args_list[2]
    
    with contextlib.suppress(KeyError):
        # for some reason args_list[6]["icon_data"][6] i.e. the byte data
        # does not change unless I restart spotify but, the song title
        # (body / summary) change gets picked up.
        details["icon_path"] = save_img_byte(args_list[6]["image-data"])
    print(json.dumps(details))


DBusGMainLoop(set_as_default=True)

rules = [
    "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"
]

bus = dbus.SessionBus()
dbus_obj = bus.get_object('org.freedesktop.DBus', '/org/freedesktop/DBus')
dbus_interface = dbus.Interface(dbus_obj, 'org.freedesktop.DBus.Monitoring')
dbus_interface.BecomeMonitor(rules, 0)
bus.add_message_filter(message_callback)

loop = GLib.MainLoop()
try:
    loop.run()
except KeyboardInterrupt:
    bus.close()

# vim:filetype=python