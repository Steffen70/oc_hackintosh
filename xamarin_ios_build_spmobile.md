### SPMobile Xamarin Build - iOS

1. Install XCode 13
2. Install Visual Studio for Mac
3. Install Xamarin.iOS (in Visual Studio for Mac)
4. Download Provisioning Profile via Apple Developer

```bash
# Clean the project
msbuild SPMobile.iOS.csproj /t:clean /p:Configuration={1} /p:Platform=iPhone

# Build the project - Release
msbuild SPMobile.iOS.csproj /t:build /p:BuildIpa=True /p:Configuration=Release /p:Platform=iPhone /p:CodesignKey="iPhone Distribution" /p:CodesignProvision="demo.swisspension.net AppStore"

# Build the project - Debug
msbuild SPMobile.iOS.csproj /t:build /p:BuildIpa=True /p:Configuration=Debug /p:Platform=iPhone /p:CodesignKey="iPhone Developer" /p:CodesignProvision="development.demo.swisspension.net Development"
```
