-- Imported from https://forum.artixlinux.org/index.php/topic,4230.0.html
-- Needed to allow Bluetooth audio to work in CLI

-- Disable arbitration of user allowance of bluetooth via D-Bus user session
bluez_monitor.properties["with-logind"] = false
