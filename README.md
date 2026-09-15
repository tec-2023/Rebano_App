# 🐑 Rebaño - Sistema de Gestión Eclesiástica Multi-Tenant

[![Flutter](https://img.shields.io/badge/Flutter-3.32.6-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-4CAF50)](#arquitectura)
[![State Management](https://img.shields.io/badge/State-Provider-orange)](https://pub.dev/packages/provider)
[![Platform](https://img.shields.io/badge/Platform-Android%20APK-brightgreen?logo=android)](https://android.com)

**Rebaño** es una plataforma SaaS (Software as a Service) móvil con arquitectura Multi-Tenant diseñada para la gestión integral de congregaciones e iglesias cristianas. Desarrollada para distribución directa como archivo **APK para Android** (fuera de Google Play Store).

---

## 🌟 Pilares y Reglas de Negocio

1. **Aislamiento Multi-Tenant & Marca Blanca (White-Label):**
   * Toda la app responde reactivamente al `TenantProvider`, el cual controla `churchName`, `churchCode` (ej. `REB-1054`), `logoUrl` y `primaryColor`.
   * Incluye 7 paletas de colores litúrgicos/modernos para adaptarse visualmente a la identidad de cada congregación en tiempo real.

2. **Roles Acumulativos (RBAC):**
   * Matriz de roles acumulativa: `['miembro', 'lider_celula', 'tesorero', 'admin']`.
   * La navegación inferior (`BottomNavigationBar`) y el menú lateral (`Drawer`) ocultan o muestran módulos dinámicamente según los permisos del usuario activo.
   * Incluye un selector rápido de roles para pruebas en modo demo.

3. **Sistema de Distribución y Actualizaciones (OTA):**
   * Detección en el *Splash Screen* de versiones más recientes en la nube con diálogo bloqueante y botón para descargar el APK independiente (`url_launcher`).

4. **Soporte Voluntario ("Apoyar este Ministerio"):**
   * Integración en el menú lateral con enlace directo a WhatsApp y mensaje precargado.

---

## 📱 Módulos Implementados

### 🕊️ 1. Red de Oración (Acceso: Todos)
* **Muro de Peticiones:** Feed interactivo categorizado (Salud, Familia, Finanzas, Espiritual, Alabanza).
* **Interacciones:** Contador y botón *"Unirme en Oración"* y botón *"¡Dios Respondió!"* con celebración y testimonios.
* **Encargado del Día:** Banner superior que destaca al intercesor de la jornada con versículo y enfoque.

### 👥 2. Células y Evangelismo (Acceso: `admin`, `lider_celula`)
* **Gestión Celular:** Control de anfitrión, horario semanal y lista de miembros.
* **Asistencia Rápida:** Pase de lista interactivo con porcentaje de asistencia en vivo.
* **Rutas de Evangelismo:** Mapa interactivo (`flutter_map` / OpenStreetMap) que fija el **Punto de Reunión** (casa semanal) a las **5:00 PM**, trazado de calles y listado de manzanas.
* **Reporte Post-Reunión:** Envío de estadísticas de asistencia, visitas nuevas, tratados entregados y ofrendas.

### 💰 3. Tesorería y Finanzas (Acceso: `admin`, `tesorero`)
* **Dashboard Financiero:** Tarjetas de Saldo Disponible, Ingresos del Mes y Egresos del Mes.
* **Transacciones:** Formularios separados para Ingresos (diezmos, ofrendas, donante opcional) y Egresos (servicios, alquiler, ministerios).
* **Respaldo Digital:** Captura y simulación fotográfica de notas y facturas físicas (`image_picker`).
* **Exportación a Excel:** Generador de reportes en formato CSV/Excel y selector nativo para compartir (`share_plus`).

### ⚙️ 4. Administración (Acceso: `admin`)
* **Personalización Marca Blanca:** Cambio de nombre y selector en vivo de temas litúrgicos.
* **Gestión de Miembros:** Asignación dinámica de roles acumulativos mediante modal con checkboxes.

### 🔑 5. Flujo de Autenticación & Onboarding
* **Ruta A (Pastor/Admin):** Registro de congregación con generación de código `REB-XXXX` y pantalla de felicitación con botón para compartir.
* **Ruta B (Miembro):** Validación del código de iglesia y registro del usuario asignando rol base `miembro`.
* **Cuentas Demo:** Acceso instantáneo con 1 solo toque para pruebas de cada perfil de rol.

---

## 🏗️ Arquitectura de Software

Implementado con **Clean Architecture** y separación por capas:
* **`core/`**: Temas, colores de marca blanca, formateadores de moneda/fecha y componentes visuales reutilizables.
* **`features/`**: Módulos independientes estructurados en `domain/` (entidades y contratos), `data/` (mock repositories desacoplados listos para Supabase) y `presentation/` (controladores Provider y pantallas).

---

## 🚀 Cómo Ejecutar el Proyecto

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/Rebano_App.git
   cd Rebano_App
   ```

2. Descargar dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecutar análisis y pruebas:
   ```bash
   flutter analyze
   flutter test
   ```

4. Ejecutar la aplicación en Android o emulador:
   ```bash
   flutter run
   ```
