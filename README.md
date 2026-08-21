# KlkMax 2

**Control personal de horas extra** — App offline para Android hecha con Flutter.

## Características

- Botones **Inicio / Terminado** con cronómetro en tiempo real
- Reloj en formato **12 horas**
- Cálculo automático de horas normales y extra
- **3 turnos editables**: Diurno, Vespertino y Nocturno
- Entrada manual de horas (cualquier día de la semana)
- Días feriados editables
- Reporte **PDF quincenal** descargable
- Calendario con notas/recordatorios
- Notas independientes
- Calculadora
- Historial completo de sesiones
- PIN de seguridad
- Foto de perfil y datos personales
- Temas de colores vivos (neón)
- 100% offline — datos solo en tu móvil

## Cómo generar el APK

### Requisitos
- Flutter 3.22+ instalado ([instalación](https://docs.flutter.dev/get-started/install))
- Android SDK (viene con Android Studio o cmdline-tools)

### Pasos

```bash
# 1. Clona el repositorio
git clone https://github.com/klkmax/klkmax2.git
cd klkmax2

# 2. Obtén las dependencias
flutter pub get

# 3. Genera el APK de release
flutter build apk --release
```

El APK quedará en:
`build/app/outputs/flutter-apk/app-release.apk`

### Solo para ARM64 (más ligero y rápido)

```bash
flutter build apk --release --target-platform android-arm64
```

### Generar ícono personalizado (opcional)

Coloca tu logo en `assets/images/logo_km.png` y ejecuta:

```bash
flutter pub run flutter_launcher_icons
```

## Estructura principal

```
lib/
├─ main.dart
├─ theme/
├─ models/
├─ services/
├─ screens/
├─ widgets/
└─ utils/
```

## Licencia

Uso personal.
