# Documentación: Funcionalidad de Rutina Diaria

## Descripción General
La funcionalidad de **Rutina Diaria** ha sido diseñada para mejorar la retención de los usuarios en la plataforma y estructurar sus sesiones de grabación de voz. En lugar de requerir que el paciente busque manualmente etiquetas o el término "Syllabus" en un buscador, la rutina proporciona un "Modo de Entrenamiento Guiado" continuo. 

Cuando el usuario inicia una rutina, se le presenta un tren ininterrumpido de 5 frases propuestas por el backend. Al finalizar de grabar cada una, el sistema evalúa en sesión cuál es la siguiente y lo redirige automáticamente hasta finalizar.

## Flujo del Usuario
1. El usuario (cliente) inicia sesión en el sistema Lara.
2. En la pantalla principal (`/cliente-tag`), se evalúa si el usuario ya completó la rutina hoy mediante el campo `ultima_rutina` en la base de datos.
3. Si no la ha completado, se muestra una tarjeta destacada informándole de que tiene una rutina diaria preparada.
4. Al hacer clic en el botón "Empezar Entrenamiento", el backend verifica la disponibilidad y genera una cola de 5 archivos (`ObjectId` de Syllabus) en memoria de sesión, inyectando el parámetro `?routine=1` para forzar el flujo de rutina.
5. El sistema redirige automáticamente a la pantalla de grabación (`/client-record`) para la primera etiqueta.
6. Durante la grabación, una barra de progreso muestra la etapa actual (por ejemplo: `Frase 1 de 5`).
7. En lugar del botón "Enviar", aparece un botón adaptativo inteligente "Guardar y Siguiente" o "Finalizar Rutina" según corresponda.
8. Al guardar la última frase, tras el éxito, SweetAlert notifica con el mensaje **"Ruta diaria completada, felicidades"**, registra la finalización en base de datos y vuelve a redireccionar a la portada de etiquetas de manera limpia. El banner de rutina ya no aparecerá hasta el día siguiente.

## Archivos Modificados

### 1. `pialara/blueprints/audios.py` (Controlador)
* **Nuevo Endpoint (`@bp.route('/client-routine')`)**: Lógica que construye la rutina. Aplica un `aggregate` con `$sample: { size: 5 }` sobre la colección de syllabus, extrae los identificadores, y registra el estado en `session['routine_items']` y un índice `session['routine_index']`. Previamente, verifica en la colección `Usuario` si `ultima_rutina` coincide con el día de hoy para denegar el acceso si ya se completó. Redirige a `/client-record/` con el query param `?routine=1`.
* **Ruta de grabación (`@bp.route('/client-record/')`)**: Añadida lógica condicional `if request.args.get('routine') == '1' and 'routine_items' in session`. Si existe la sesión y el parámetro, avanza inyectando `routine_data = {"current": index+1, "total": 5}` hacia la plantilla HTML. Si el parámetro falta, asume navegación manual, abortando y limpiando cualquier sesión de rutina abandonada para evitar reactivaciones involuntarias.
* **Guardado de Audio (`@bp.route('/save-record')`)**: Tras grabar un elemento satisfactoriamente (`audio.insert_one()`), el controlador avanza `session['routine_index'] += 1`. Si quedan frases, expone por JSON la variable `next_routine_url` manteniendo `?routine=1`. Si el array terminó, altera el booleano `"is_routine_completed": True`, destruye la variable en sesión con `session.pop()`, y actualiza o establece `ultima_rutina`: `datetime.now()` en el documento del usuario en la base de datos para registrar la persistencia.

### 2. `pialara/templates/audios/client_tag.html` (Vista de inicio Cliente)
* Añadido al principio del `<section>` un elemento UI `<div class="card text-center border-primary shadow-sm w-100">` con un Call-To-Action (CTA) invitante a usar el generador automatizado. Este banner está condicionado por Jinja (`{% if not routine_completed_today %}`) para desaparecer cuando la rutina diaria ya ha sido completada.

### 3. `pialara/templates/audios/client_record.html` (Vista de Grabación)
* **Barra de Progreso**: Integración de variables de Jinja `{% if routine_data %}`. Se calcula el progreso dinámico generando un `<div class="progress-bar">` que se llena del 20% al 100%.
* **Etiqueta del botón de envío**: Bloquecito simple `{% if routine_data.current < routine_data.total %}` para cambiar visualmente de "Enviar" al comportamiento natural esperado de "Guardar y Siguiente".

### 4. `pialara/static/js/speech-recording.js` (Script AJAX Frontend)
* Reescrita e inyectada la lógica de control del Modal `swal()`. En el evento AJAX `.done(...)`:
  * En un flujo normal, al pulsar en "Grabar otro audio" el navegador dispara un vulgar `window.location.reload()`.
  * En un flujo modo rutina, el script rescata la URL devuelta dinámicamente (`window.location.href = data.next_routine_url`). Este enrutamiento dinámico es imperceptible al usuario de forma que el paso entre frases se sienta veloz y no como cargar páginas nuevas manuales. Al finalizar, personaliza el título del SwitchAlert con "Ruta diaria completada, felicidades".
