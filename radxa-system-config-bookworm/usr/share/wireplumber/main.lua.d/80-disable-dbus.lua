-- Imported from https://forum.artixlinux.org/index.php/topic,4230.0.html
-- Needed to allow Bluetooth audio to work in CLI

-- Disable reserving devices via D-Bus user session
alsa_monitor.properties["alsa.reserve"] = false
-- Disable use of flatpak portal integration
default_access.properties["enable-flatpak-portal"] = false
