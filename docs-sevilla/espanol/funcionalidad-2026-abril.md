# Funcionalidad: Internacionalización y Traducción al Inglés (Abril 2026)

## Descripción General
La funcionalidad de Abril introduce soporte multiidioma a la plataforma Lara, permitiendo a los usuarios alternar entre Español (idioma por defecto) e Inglés. Esta característica mejora la accesibilidad del sistema para usuarios internacionales.

## Flujo de Interacción
1. **Selección de Idioma**: En el menú principal de navegación (layout), el usuario dispone de un botón dedicado para cambiar el idioma (iconos 'EN' y 'ES').
2. **Cambio de Sesión**: Al hacer clic en el botón, se hace una petición a la ruta correspondiente (ej. `/set_language/en`). Flask actualiza la variable de sesión `session['lang']` y recarga la página actual.
3. **Renderizado Dinámico**: Todos los textos estáticos del HTML se sustituyen automáticamente por su correspondiente versión en inglés antes de enviarse al navegador del usuario.

## Detalles Técnicos y Arquitectura

### 1. Sistema Base: Flask-Babel
El motor principal utilizado para la internacionalización es `Flask-Babel`. Esta librería proporciona las funciones necesarias para marcar, extraer y compilar las cadenas de texto a traducir.

### 2. Modificaciones en el Frontend (Jinja2)
En todas las plantillas (como `client_record.html`, `calendario_rachas.html` o `users/update.html`), las cadenas literales estáticas han sido envueltas en la función de traducción `_()`.
*Ejemplo:* `<h1>{{ _('Calendario de Rachas') }}</h1>`

Para el caso de textos definidos en archivos estáticos `.js` (como los modales de alerta de *SweetAlert* en `speech-recording.js`), se inyectan variables globales en la cabecera de la plantilla (`window.translations`) para que el JavaScript pueda leer la cadena previamente traducida por Jinja.

### 3. Modificaciones en el Backend
* Rutas y Controladores: Algunos mensajes de retorno en peticiones AJAX (`jsonify` en `audios.py`) han sido envueltos de manera nativa utilizando `from flask_babel import _`.
* Los selectores dinámicos y menús de opciones en HTML también se traducen iterativamente pasando las variables por la función de traducción de Babel.

### 4. Diccionarios de Traducción
Los archivos base que contienen el mapeo de los textos están alojados en la ruta `pialara/translations/en/LC_MESSAGES/`:
* `messages.po`: Archivo de texto legible donde se especifican los identificadores originales en español y sus valores `msgstr` en inglés.
* `messages.mo`: El binario compilado utilizado por el servidor para la rápida asignación en tiempo de ejecución.
