{
  description = "Flutter 3.19.x";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersion = "34.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [
            buildToolsVersion
            "30.0.3"
          ];
          platformVersions = [
            "34"
            "33"
            "29"
            "28"
          ];
          abiVersions = [
            "armeabi-v7a"
            "arm64-v8a"
          ];
        };
        androidSdk = androidComposition.androidsdk;
        flutter = pkgs.flutter319;
      in
      {
        devShell =
          with pkgs;
          mkShell rec {
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/34.0.0/aapt2";
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            JAVA_HOME = "${jdk17.home}";
            CHROME_EXECUTABLE = "${chromium}/bin/chromium";
            buildInputs = [
              flutter # flutter316  flutter313 flutter=3.19
              androidSdk # The customized SDK that we've made above
              gradle # Gradle=8.6 gradle_7 gradle_6
              jdk17 # 最好指定版本，不然可能需要处理gradle和jdk版本的兼容 jdk="21"
              #ninja cmake glibc # linux下调试桌面应用用 需要自行装到 home.packages 装这里可能有问题，c和rust也需要所以不写这里
              fish
              chromium
              #jetbrains.idea-ultimate
            ];
            shellHook = ''
              ${flutter}/bin/flutter --version
              echo " 你可能需要运行下面的命令 "
              echo " rm -rf ~/.pub-cache  "
              echo " rm -rf ~/.gradle  "
              echo " rm -rf ~/.dart  "
              echo " rm -rf ~/.dartServer  "
              echo " flutter pub get "
              export SHELL=${fish}/bin/fish
              exec fish
            '';
          };
      }
    );
}
