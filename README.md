# ScreenTimeApp

## Setup

1. Go to the targets of the project and change the bundle identifier that starts with "fr.devj2k" to your organization identifier in the `ScreenTimeApp` and `DeviceActivityMonitorExtension` targets. The bundle identifier for the `ScreenTimeApp` target should look like this: `"yourOrganizationIdentifier.ScreenTimeApp"` and for the `DeviceActivityMonitorExtension` target, it should look like this: `"yourOrganizationIdentifier.ScreenTimeApp.DeviceActivityMonitorExtension"`.

2. Still in targets, create a new group in "App Groups" named `"group.yourOrganizationIdentifier.ScreenTimeApp"` and select this group. Both targets should be in the same group.

3. Go to `ScreenTimeApp > MyModel > line 14`: Change the value of `appGroup` from `"group.fr.devj2k.ScreenTimeApp"` to your group name.

## Notes

- You need to have a developer account membership for this app to work.
- Then go to [developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list).
- You have to create a new identifier by App ID type. The Bundle ID is `"yourOrganizationIdentifier.ScreenTimeApp"` and the description is the name of the identifier.
- Select the "App Groups" and "Family Controls (Development)" capabilities. Click on "Continue" then "Register".
