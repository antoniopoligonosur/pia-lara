# Funcionalidad de Valoración de Audios

Esta funcionalidad permite a los usuarios calificar la dificultad de pronunciación de una frase inmediatamente después de grabar y enviar un audio. El objetivo es recoger feedback sobre la complejidad de los ejercicios.

## Flujo de Interacción

1.  **Grabación y Envío**:
    *   El usuario graba un audio y pulsa el botón "Enviar".
    *   El sistema muestra un indicador de carga ("espere...") mientras se sube el archivo al servidor.

2.  **Aparición del Modal**:
    *   Una vez que el servidor confirma que el audio se ha guardado correctamente, aparece un modal (ventana emergente).
    *   Este modal utiliza la librería `SweetAlert`.

3.  **Interfaz de Valoración**:
    *   El modal muestra la pregunta: **"¿Qué tan fácil te resultó pronunciar esta frase?"**.
    *   Muestra una escala de 5 estrellas interactiva.
    *   Tiene etiquetas explicativas en los extremos: "Muy difícil" (1 estrella) y "Muy fácil" (5 estrellas).

4.  **Interacción con las Estrellas**:
    *   **Hover**: Al pasar el ratón por encima de las estrellas, estas se iluminan para indicar la selección potencial.
    *   **Click**: Al hacer clic en una estrella, se fija la valoración.

5.  **Guardado de la Valoración**:
    *   Al seleccionar una estrella, se envía automáticamente una petición al servidor (`POST /audios/save-rating`) con el ID del audio y la puntuación (de 1 a 5).
    *   Si el guardado es exitoso, aparece un mensaje en color verde: **"¡Valoración guardada!"**.

6.  **Finalización**:
    *   El modal incluye un botón **"Grabar otro audio"**.
    *   Al pulsarlo, la página se recarga para permitir al usuario realizar un nuevo ejercicio.

## Detalles Técnicos

### Archivos Relevantes

*   **Frontend (Lógica)**: `pialara/static/js/speech-recording.js`
    *   Maneja la visualización del modal tras la respuesta AJAX de subida de audio.
    *   Gestiona los eventos de ratón (mouseenter, mouseleave, click) sobre las estrellas.
    *   Realiza la petición AJAX para guardar la valoración.
*   **Frontend (Plantilla)**: `pialara/templates/audios/client_record.html`
    *   Contiene la estructura HTML del modal dentro de un `div` oculto con id `rating-template`.
    *   Define las clases e iconos (Bootstrap Icons) para las estrellas.

### Implementación del Modal

El modal se construye clonando un elemento oculto del DOM (`#rating-template`) e inyectándolo en una alerta de SweetAlert. Esto permite reutilizar la estructura HTML y mantener la lógica de eventos separada.
