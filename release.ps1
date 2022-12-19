flutter pub run change_app_package_name:main com.valliyv.colour_picker
flutter pub run flutter_launcher_name:main
flutter pub run flutter_launcher_icons -f windows_config.yaml
flutter build windows --release --no-sound-null-safety
$pfx_path = "windows/cert.pfx";
$decoded_bytes = [System.Convert]::FromBase64String($env:BASE64_PFX);
Set-Content $pfx_path -Value $decoded_bytes -AsByteStream;
flutter pub run msix:create --install-certificate false --certificate-password $env:CERT_PASSWORD
