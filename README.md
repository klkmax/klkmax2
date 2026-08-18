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

```bash
flutter pub get
flutter build apk --release
```

El APK quedará en:
`build/app/outputs/flutter-apk/app-release.apk`

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
