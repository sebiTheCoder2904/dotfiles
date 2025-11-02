import os
import json
import configparser

desktop_dirs = [
    "/usr/share/applications",
    os.path.expanduser("~/.local/share/applications")
]
icon_dirs = [
    "/usr/share/icons/hicolor/48x48/apps",
    "/usr/share/pixmaps",
    os.path.expanduser("~/.local/share/icons/hicolor/48x48/apps")
]

apps = []

def find_icon(icon_name):
    # Try direct path
    if os.path.isabs(icon_name) and os.path.isfile(icon_name):
        return icon_name
    # Try with .png extension in icon_dirs
    for icon_dir in icon_dirs:
        png_path = os.path.join(icon_dir, icon_name + ".png")
        if os.path.isfile(png_path):
            return png_path
        # Try without extension
        noext_path = os.path.join(icon_dir, icon_name)
        if os.path.isfile(noext_path):
            return noext_path
    return None

for desktop_dir in desktop_dirs:
    if not os.path.isdir(desktop_dir):
        continue
    for fname in os.listdir(desktop_dir):
        if fname.endswith(".desktop"):
            fpath = os.path.join(desktop_dir, fname)
            config = configparser.ConfigParser(strict=False)
            try:
                config.read(fpath)
                entry = config["Desktop Entry"]
                name = entry.get("Name")
                icon = entry.get("Icon")
                if name and icon:
                    icon_path = find_icon(icon)
                    if icon_path:
                        apps.append({
                            "name": name,
                            "icon": icon_path
                        })
            except Exception:
                continue

with open("apps.json", "w") as f:
    json.dump(apps, f, indent=2)