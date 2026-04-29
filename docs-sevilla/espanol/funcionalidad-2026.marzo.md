# Documentación Técnica: Sistema de Rachas y Módulo de Actividad (Marzo 2026)

## Resumen Funcional
El módulo de actividad tiene como objetivo principal el seguimiento y la visualización de la constancia del usuario. Se basa en una racha de días consecutivos de grabación y una interfaz de calendario que resume la actividad mensual por usuario.

## Arquitectura del Sistema de Rachas
El sistema de rachas funciona mediante una validación de fechas cada vez que el servidor recibe una nueva grabación.

### Lógica de Control (Servidor)
Ubicada en el controlador de audios, la lógica compara la fecha actual con la fecha de la última grabación registrada para el usuario:
* **Incremento**: Si la diferencia entre hoy y el último día grabado es de exactamente un día, el sistema incrementa el valor de la racha almacenado en el perfil del usuario.
* **Mantenimiento**: Si el usuario graba hoy y ya ha grabado previamente hoy, la racha no varía.
* **Reinicio**: Si la diferencia es superior a un día, la racha se restablece a 1, indicando que el ciclo de constancia se ha roto.

Los datos se persisten en la colección de usuarios de la base de datos, manteniendo actualizados los campos `racha_actual` y `ultima_grabacion`.

## Implementación del Calendario de Actividad
La vista del calendario (`/calendario-rachas`) es un componente dinámico que organiza la actividad del usuario de forma mensual.

### Procesamiento de Datos
Para generar la vista, el servidor realiza las siguientes tareas:
1. **Generación de Mes**: Utiliza librerías de calendario para crear una cuadrícula de semanas y días correspondiente al mes y año solicitados.
2. **Conteo de Actividad**: Realiza una consulta a la base de datos de grabaciones filtrando por el usuario y el rango de fechas del mes. Se genera un mapa que asocia cada día del mes con el número total de audios grabados.
3. **Identificación Temporal**: Se marca el día actual para que la interfaz pueda resaltarlo respecto al resto del mes.

### Visualización en la Interfaz (Frontend)
La plantilla utiliza lógica condicional para determinar el estilo de cada celda del calendario:
* **Estado "Hoy"**: Una celda resaltada con el color principal del sistema (azul) para ubicación rápida.
* **Estado "Actividad"**: Celdas con fondo naranja y un indicador numérico que muestra la cantidad de audios grabados ese día.

## Integración de la Rutina Diaria
El módulo centraliza también el acceso a la rutina diaria de ejercicios. Esta se presenta como una tarjeta informativa debajo del calendario, permitiendo al usuario ver su progreso y saltar directamente a los 5 ejercicios recomendados para el día, cohesionando así la revisión de actividad con la ejecución de tareas.

## Accesibilidad y Diseño Responsivo
El módulo implementa un sistema de estilos dinámicos de alto contraste. Mediante clases aplicadas al cuerpo de la página, el calendario y la tarjeta de rutina ajustan sus colores, bordes y visibilidad de iconos para los tres modos de accesibilidad (`contrast-1`, `contrast-2`, `contrast-3`), asegurando que todos los componentes clave sean legibles en configuraciones de monitores de alta visibilidad.

## Archivos y su Función en el Módulo
* **`pialara/blueprints/audios.py`**: Es el cerebro del módulo. Calcula las rachas al guardar audios y prepara la estructura de datos del calendario (días, meses, conteos) para enviarlos a la vista.
* **`pialara/templates/audios/calendario_rachas.html`**: Define la estructura visual. Contiene la lógica para pintar las celdas según su estado y los estilos CSS específicos para los modos de accesibilidad y el diseño adaptativo.
* **`pialara/templates/layout.html`**: Gestiona la visibilidad del acceso al calendario en el menú de navegación principal para los usuarios con el rol adecuado.
* **`pialara/models/User.py`**: Define la estructura del objeto usuario donde se almacenan persistente los valores de racha y fechas de grabación.
