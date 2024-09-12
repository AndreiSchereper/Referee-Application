# App Installation Guide for Windows

Here is the official installation guide for Flutter: [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

## Install Docker

### Download Docker Desktop
- Go to the [Docker Desktop download page](https://www.docker.com/products/docker-desktop).
- Click on the "Download for Windows" button.

### Install Docker Desktop on Windows
1. Once the download is complete, locate the downloaded file (usually in your Downloads folder) and double-click the `Docker Desktop Installer.exe` file.
2. Follow the instructions in the setup wizard. Click "Next" to continue.
3. Read the license agreement, then click "I accept the terms in the License Agreement" and click "Next".
4. Choose the destination location for the installation. The default location is usually fine. Click "Next".
5. Select the additional tasks you want to perform, such as enabling WSL 2 features. Click "Next".
6. Click "Install" to begin the installation process.
7. Once the installation is complete, click "Finish" to exit the setup wizard.
8. Docker Desktop will start automatically. Follow any additional on-screen instructions to complete the setup.

### Verify Docker Installation
1. Open a terminal.
2. Run the following command to verify the installation: docker --version


## Running Docker Compose
1. Navigate to your project directory in the terminal.
2. Run the following command to start your Docker containers: docker compose up --build

## Download and Install Visual Studio Code

### Download Visual Studio Code
- Go to the [Visual Studio Download Page](https://code.visualstudio.com/Download).
- Click on the "Download for Windows" button.

### Install Visual Studio Code on Windows
1. Once the download is complete, locate the downloaded file (usually in your Downloads folder) and double-click the `VSCodeSetup.exe` file.
2. You will see a setup wizard. Click "Next" to continue.
3. Read the license agreement, then click "I accept the agreement" and click "Next".
4. Choose the destination location for the installation. The default location is usually fine. Click "Next".
5. Select the additional tasks you want to perform, such as creating a desktop icon. It's recommended to check "Add to PATH" and "Add context menu entries" for easier access. Click "Next".
6. Click "Install" to begin the installation process.
7. Once the installation is complete, click "Finish" to exit the setup wizard. If you want to launch Visual Studio Code immediately, make sure the "Launch Visual Studio Code" checkbox is checked.

### Install Plugins
- Go to Extensions and Install the Flutter and Dart plugins.

## Download and Install Visual Studio Community 2022

### Download Visual Studio Community 2022
- Open your web browser and navigate to the [Visual Studio website](https://visualstudio.microsoft.com/).
- Click on the "Download Visual Studio" button.
- On the download page, find the "Community 2022" section and click "Free download".

### Install Visual Studio Community 2022
1. Once the download is complete, locate the downloaded file (usually in your Downloads folder) and double-click the `vs_community.exe` file.
2. The Visual Studio Installer will launch. Click "Continue" to proceed.

### Select Workloads
1. After the installer prepares, you will be presented with the Workloads screen.
2. Locate the "Desktop & Mobile" section and check the "Desktop development with C++" workload.

### Start the Installation
1. Once you've selected your workloads and components, click the "Install" button at the bottom right of the installer.
2. The installer will start downloading and installing Visual Studio Community 2022 along with the selected components. This process may take some time depending on your internet speed and computer performance.

## Download and Install Android Studio

### Download Android Studio
- Open your web browser and navigate to the [Android Studio website](https://developer.android.com/studio).
- Click on the "Download Android Studio" button.
- Read and accept the terms and conditions, then click "Download".

### Install Android Studio on Windows
1. Once the download is complete, locate the downloaded file (usually in your Downloads folder) and double-click the `android-studio.exe` file.
2. The Android Studio setup wizard will appear. Click "Next" to continue.
3. Choose the components you want to install (Android Studio and Android Virtual Device). Click "Next".

### Additional Steps
1. Install the Dart and Flutter Plugins from the main page of Android Studio.
2. Click on “More Actions” on the main page of Android Studio and then on “SDK Manager”.
3. Make sure “Android SDK” is selected from the “Languages and Frameworks” dropdown.
4. Click on “SDK Tools” in the top center of the screen.
5. Check the “Android SDK Command-line Tools” and click Apply.
6. Click on “More Actions” on the main page of Android Studio and then on “Virtual Device Manager”.
7. Click on the 3 dots on the right side of the screen and click on "Edit"
8. Click on "Advanced Settings" and then change the front camera to a camera you have (probably named "Webcam0")

## Download and Install Git

### Download Git
- Open your web browser and navigate to the [Git website](https://git-scm.com/).
- Click on the "Download" button. The website should automatically detect your operating system (Windows, macOS, or Linux) and offer the appropriate download.

### Install Git
1. Once the download is complete, locate the downloaded file (usually in your Downloads folder) and double-click the `Git-*.exe` file.
2. You will see the Git setup wizard. Click "Next" to continue.
3. Choose the installation location and click "Next".
4. Select components you want to install. It's usually best to leave the default selections. Click "Next".
5. Choose the start menu folder and click "Next".
6. Select the default editor used by Git. You can stick with Vim (default) or choose another editor like Notepad++. Click "Next".
7. Adjust your PATH environment. Choose "Git from the command line and also from 3rd-party software" for the best compatibility. Click "Next".
8. Select the SSH executable. Use the OpenSSH that comes with Git. Click "Next".
9. Select HTTPS transport backend. Choose "Use the OpenSSL library". Click "Next".
10. Configure line ending conversions. Choose "Checkout Windows-style, commit Unix-style line endings". Click "Next".
11. Configure terminal emulator. Use "Use MinTTY (the default terminal of MSYS2)". Click "Next".
12. Configure extra options (optional) and click "Next".
13. Click "Install" to begin the installation.
14. Once the installation is complete, click "Finish".

## Download and Install Flutter SDK

### Download Flutter SDK
- Go to the [Flutter SDK download page](https://docs.flutter.dev/get-started/install/windows).
- Scroll until you find the “Install the Flutter SDK” header.
- Click on “Download and Install”.
- Click on “flutter_windows.zip” and download it.

### Extract the ZIP File
- Extract the zip file and place the contained `flutter` in the desired installation location (e.g., `C:\src\flutter`; do not install Flutter in a directory that requires elevated privileges).

### Update your Path
1. Open the Start Search, type in "env", and select "Edit the system environment variables".
2. Click "Environment Variables" in the System Properties window.
3. Under "User variables" check if there is an entry called Path:
   - If the entry exists, append the full path to `flutter\bin`.
   - If the entry does not exist, create a new user variable named Path with the full path to `flutter\bin`.

### Run Flutter Doctor
1. Open a new command prompt and run the following command to verify the installation: `flutter doctor`.
2. Type: `flutter doctor -–android-licenses`.
3. Accept everything by pressing “y”.

## Run the Project
1. Open the project folder in Visual Studio Code.
2. Create a new terminal.
3. Change the directory to the frontend folder by typing `cd` followed by the full path of the `referee_flutter_app` folder found in the “fronted folder”.
4. Type `flutter doctor` to check that everything is fine.
5. Type `flutter pub get`.
6. In the bottom right part of the screen you should find something called “Windows (windows-x64)”.
7. When found, click on it and press on “Start Pixel 3a API 34” (not cold boot).
8. When the phone finally loads in, type `flutter run` in the terminal.

## Debugging

If you encounter issues while running your project, you can follow these steps to troubleshoot:

1. Open the terminal.
2. Navigate to your project directory.
3. Run the following command to clean the build: flutter clean
4. Fetch the project dependencies again: flutter pub get
5. Run the project: flutter run

By following these steps, you should be able to resolve common issues related to cached or outdated build files.

