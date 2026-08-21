# Configurar firma de release (Keystore)

## 1. Generar el keystore (solo una vez)

En la carpeta del proyecto ejecuta:

```bash
keytool -genkey -v -keystore android/klkmax-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias klkmax
```

Te pedirá:
- Contraseña del keystore (guárdala bien)
- Contraseña de la clave (puede ser la misma)
- Nombre, organización, etc. (puedes poner lo que quieras)

## 2. Crear el archivo key.properties

Copia el ejemplo:

```bash
cp android/key.properties.example android/key.properties
```

Edita `android/key.properties` y pon tus datos reales:

```properties
storePassword=LA_CONTRASEÑA_QUE_PUSISTE
keyPassword=LA_CONTRASEÑA_QUE_PUSISTE
keyAlias=klkmax
storeFile=../klkmax-release-key.jks
```

## 3. Generar el APK firmado

```bash
flutter build apk --release
```

El APK firmado quedará en:
`build/app/outputs/flutter-apk/app-release.apk`

## Importante

- **Nunca** subas `key.properties` ni el archivo `.jks` a GitHub (ya están en `.gitignore`).
- Guarda una copia segura del `.jks` y las contraseñas. Si los pierdes no podrás actualizar la app en Play Store.
