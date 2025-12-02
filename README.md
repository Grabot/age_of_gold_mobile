# Age of Gold
The mobile social and authorization wrapper for the game Age of Gold!


## Things to do when starting a new project

### create and apply a new icon

To create a new icon you have to add a nice looking icon in the assets/images folder. You also have to add this to the pubspec.yaml to be included in the project. Also make sure the same image is defined in the `flutter_launcher_icons` subsection in the pubspec.yaml. Now run `dart run flutter_launcher_icons` and the icon should be set for both Android and IOS

### create and apply a new splash screen

Similarly you can update the splash screen to be more in line with your project by again adding an image, can be the same image, to the assets folder and the pubspec.yaml. Then make sure the same image is defined in the `flutter_native_splash` subsection in the pubspec.yaml. Make sure it is correctly set in the `flutter_native_splash` subsection. Now run `dart run flutter_native_splash:create` and the splash screen should be set for both Android and IOS.

### Add the correct app name

To change the app name you have to update the `name` field in the pubspec.yaml. Change the `android:label` field in the AndroidManifest.xml and the `<key>CFBundleDisplayName</key>` in the info.plist

### Create the oauth2 logging clients

#### Reddit

1. Go to https://www.reddit.com/prefs/apps
2. Click on the create app button
3. Select web app
4. Fill in the name
5. Fill in the redirect uri

#### Github

1. Go to https://github.com/settings/applications/new
2. Fill in the name
3. Fill in the redirect uri

#### Apple

0. Make sure you have an app id created on https://appstoreconnect.apple.com/. To be sure you can upload an initial placeholder app to the store to ensure that it is all correct.
1. Go to https://developer.apple.com/account/resources/identifiers/list/serviceId
2. Select App ID of the app you want to use
4. Select Sign in with Apple
5. Click on continue
6. Register
7. Click Services IDs
8. Click on the create button
9. Select Sign in with Apple
10. Define the Domain and the return urls
11. Click on continue
12. Register

#### Google

1. Go to https://console.cloud.google.com/apis/credentials
2. Click on the create credentials button
3. Select OAuth client ID
4. Select Web application
5. Give the origins and the redirect uris
6. Click on create
7. Create a new oauth credential for Android specific
8. fill in the correct package name and the sha1 key
9. Create a new oauth credential for iOS specific
10. fill in the correct bundle id and App id that you can find in the apple overview
