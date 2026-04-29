# Documentación Técnica: Verificación de Micrófono y Modal de Advertencia

## 1. Descripción General
Esta funcionalidad implementa una validación previa a la grabación de audio en el lado del cliente. Su objetivo es asegurar que el usuario tenga un micrófono conectado y haya otorgado los permisos necesarios antes de intentar grabar, mejorando la experiencia de usuario y evitando errores de "grabación vacía".

## 2. Flujo de Ejecución
1. El usuario hace clic en el botón de grabación (`.record-button`).
2. El sistema intercepta el evento e inicia una validación asíncrona.
3. **Validación 1 (Hardware):** Se consulta `navigator.mediaDevices.enumerateDevices()` para verificar si existe algún dispositivo de tipo `audioinput`.
4. **Validación 2 (Software/Permisos):** Se verifica si la variable `currentStream` (que almacena el flujo de audio inicializado al cargar la página) está definida.
5. **Resultado:**
   - **Éxito:** Si ambas validaciones pasan, se procede con la lógica original de grabación (`mediaRecorder.start()`).
   - **Fallo:** Si falta el dispositivo o los permisos, se detiene la ejecución y se muestra el modal de advertencia (`#mic-warning-modal`).

## 3. Implementación Técnica

### 3.1. JavaScript (`speech-recording.js`)
Se ha modificado el <code>EventListener</code> del botón de grabación para que sea `async` e incluya la lógica de bloqueo.

```javascript
recordButton.addEventListener('click', async () => {
    // 1. Verificación de Hardware
    let hasMicDevice = false;
    try {
        const devices = await navigator.mediaDevices.enumerateDevices();
        hasMicDevice = devices.some(d => d.kind === 'audioinput');
    } catch (e) {
        console.error("Error enumerating devices", e);
    }

    // 2. Bloqueo si no hay hardware o no hay stream activo
    if (!currentStream && !hasMicDevice) {
         showMicWarningModal();
         return; // Detiene la grabación
    }
    
    if (!currentStream) {
        showMicWarningModal();
        return; // Detiene la grabación
    }

    // ... Continúa lógica original ...
});
```

### 3.2. HTML (`client_text.html`)
Se ha insertado un contenedor modal al final del archivo (antes de los scripts) que permanece oculto por defecto.

- **ID Principal:** `mic-warning-modal`
- **Estructura:** Overlay oscuro con una tarjeta central flotante.
- **Iconografía:** SVG incrustado representando un micrófono con una señal de alerta.

### 3.3. CSS (`style_cliente.css`)
Estilos "aditivos" agregados al final del archivo para no romper el diseño existente.

- **Clases clave:**
    - `.mic-modal-overlay`: Gestiona el fondo oscuro y el centrado (Flexbox).
    - `.mic-modal-content`: La tarjeta blanca con borde amarillo (`#ffbc42`).
    - `.mic-modal-btn`: Botón de acción para cerrar la modal.

## 4. Archivos Modificados
| Archivo | Ruta Relativa | Descripción del Cambio |
|---------|---------------|------------------------|
| **Lógica** | `pialara/static/js/speech-recording.js` | Inyección de validación asíncrona en el evento click. |
| **Estilos** | `pialara/static/styles/style_cliente.css` | Nuevas reglas CSS para el modal al final del archivo. |
| **Template** | `pialara/templates/audios/client_text.html` | Inserción del HTML del modal antes del bloque de scripts. |

## 5. Mantenimiento
- **Preservación:** El código ha sido diseñado para ser mínimamente intrusivo. Si se desea desactivar la validación, basta con comentar las líneas de validación en el JS; el HTML y CSS pueden permanecer sin afectar la visualización (ya que están ocultos por defecto).
- **Compatibilidad:** Usa APIs estándar del navegador (`navigator.mediaDevices`).

---

# Funcionalidad: Modal de Consejos para Grabación de Audio

Este componente muestra un modal con recomendaciones para grabar audio, utilizando **Bootstrap 5**.

## Estructura

- **Modal** (`#modalConsejosAudio`)
  - **Header**
    - Título: "Consejos para grabar tu audio" con ícono SVG.
    - Botón de cierre (`btn-close`).
  - **Body**
    - Texto introductorio.
    - Lista de consejos:
      1. Mantener un lugar **silencioso**.
      2. Hablar con **calma** y naturalidad.
      3. Volumen cómodo y claro.
      4. Revisar y **volver a grabar** si es necesario.
      5. Tomarse el tiempo necesario.
  - **Footer**
    - Mensaje de agradecimiento.
    - Botón "Entendido" para cerrar el modal.

- **Botón disparador**
  - Botón circular con ícono `i`.
  - Ubicación: esquina superior derecha (`position-fixed top-0 end-0`).
  - Atributos: `data-bs-toggle="modal"` y `data-bs-target="#modalConsejosAudio"`.

## Notas

- Modal centrado y de tamaño grande (`modal-dialog-centered modal-lg`).
- Compatible con dispositivos móviles y escritorio.
- Estilos personalizados para ícono y espaciado (`px-4 px-md-5`, `gap-2`).
