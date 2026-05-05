# Despliegue de PIA-LARA en Producción

El despliegue de la aplicación PIA-LARA se gestiona utilizando contenedores de Docker, orquestados mediante Docker Compose. Esto permite un entorno de ejecución predecible y replicable, ideal para su despliegue en instancias como AWS EC2. La arquitectura se compone de tres servicios principales: la base de datos (MongoDB), la aplicación web (Flask servida con Gunicorn) y un proxy inverso (Nginx) que además gestiona el tráfico seguro (HTTPS).

A continuación se detalla cómo interactúan los diferentes componentes de la arquitectura y la configuración de cada uno de los elementos clave del despliegue.

## Arquitectura de Despliegue

La arquitectura se fundamenta en un entorno multi-contenedor que aísla cada componente:

1.  **Proxy Inverso (Nginx)**: Actúa como el único punto de entrada público, recibiendo peticiones HTTP/HTTPS, redirigiendo el tráfico de forma segura al contenedor de la aplicación y gestionando la terminación SSL con certificados.
2.  **Aplicación Web (Pialara)**: Ejecuta el código de Flask a través de Gunicorn, un servidor WSGI de producción, para manejar de manera concurrente múltiples peticiones. Este contenedor se nutre de la configuración inyectada por variables de entorno y archivos `.ini` para mantener la compatibilidad con la estructura actual.
3.  **Base de Datos (MongoDB)**: Contenedor dedicado que almacena toda la información de usuarios, audios y modelos, con almacenamiento persistente en un volumen local.

### Dockerfile (Construcción de la Imagen Web)

El archivo `Dockerfile` define las instrucciones para construir la imagen de la aplicación web:

-   **Imagen Base**: Utiliza `python:3.9-slim-buster`, una versión reducida de Debian con Python 3.9 preinstalado, minimizando el tamaño final de la imagen.
-   **Variables de Entorno**: Establece `PYTHONDONTWRITEBYTECODE=1` y `PYTHONUNBUFFERED=1` para evitar archivos compilados `.pyc` innecesarios y asegurar que los logs de la aplicación se emitan de inmediato (sin almacenamiento en búfer) a la salida estándar de Docker.
-   **Directorio de Trabajo (`/app`)**: Define dónde se ejecutarán los siguientes comandos y dónde residirá el código.
-   **Dependencias**: Copia el `requirements.txt` e instala los paquetes necesarios (junto con Gunicorn) empleando `pip install --no-cache-dir` para no conservar la caché y ahorrar espacio.
-   **Directorio de Audios**: Crea de manera explícita el directorio local en `/app/pialara/static/audios` para evitar posibles errores de montado o escritura al persistir los archivos generados por la aplicación.
-   **Exposición y Ejecución**: Expone el puerto `8000` (puerto de escucha de Gunicorn dentro de la red privada de contenedores) y especifica como comando predeterminado la ejecución de la aplicación con `gunicorn --workers=4 --bind=0.0.0.0:8000 pialara:create_app()`, utilizando 4 hilos (workers) para atender concurrencia.

### Archivo `docker-compose.yml` (Orquestación de Servicios)

El `docker-compose.yml` declara cómo los servicios se agrupan y se comunican entre sí en una misma red privada (`pialara_net`):

-   **Servicio `db`**:
    -   Utiliza la imagen oficial `mongo:6.0`.
    -   Configura un volumen llamado `mongo-data` apuntando a `/data/db` dentro del contenedor para garantizar que los datos persistan frente a caídas o reinicios.
-   **Servicio `web`**:
    -   Se construye a partir del `Dockerfile` situado en el directorio actual.
    -   Define una dependencia directa con `db` (`depends_on: db`) para iniciar después de la base de datos.
    -   Utiliza volúmenes para inyectar configuraciones: se inyecta `produccion.ini` en `/app/.ini`, preservando el uso de archivos `.ini` para la configuración, como requiere el diseño actual.
    -   Mapea el directorio `./audios_local` al path interno `/app/pialara/static/audios` del contenedor. Esto es fundamental para que todos los audios guardados no se eliminen si se detiene el contenedor.
-   **Servicio `cert-generator`**:
    -   Es un servicio efímero (se ejecuta, cumple su función y termina). Verifica si ya existe un certificado SSL en el volumen `certs`. Si no existe, genera uno autofirmado mediante `openssl`. De esta forma, el servidor proxy siempre dispondrá de un certificado sin requerir intervención manual durante el arranque.
-   **Servicio `proxy` (Nginx)**:
    -   Expondrá y publicará en la máquina anfitriona (AWS) los puertos `80` (HTTP) y `443` (HTTPS).
    -   Mapea la configuración personalizada `nginx.conf` como solo lectura, e inyecta el volumen `certs` que generó el `cert-generator`.
    -   Su ejecución condiciona que el servicio `web` haya iniciado y que `cert-generator` haya finalizado exitosamente.

### Archivo `nginx.conf` (Configuración de Red y Seguridad)

Este archivo estructura el comportamiento de Nginx, el cual opera como el punto frontal:

-   **Redirección HTTP a HTTPS**: El primer bloque `server` escucha en el puerto `80` y fuerza a todos los clientes redirigiendo el tráfico con un `301` al mismo URI pero mediante HTTPS.
-   **Terminación SSL**: El segundo bloque escucha en el puerto `443 ssl` y especifica las rutas donde Nginx encuentra los certificados (`/certs/server.crt` y `/certs/server.key`). También asegura el servidor limitando los protocolos seguros permitidos a `TLSv1.2` y `TLSv1.3`.
-   **Proxy hacia la Web**: Dentro de la directiva `location /`, todas las peticiones validadas se reenvían al contenedor web interno mediante `proxy_pass http://web:8000`. Además, Nginx inyecta cabeceras (headers) como `Host`, `X-Real-IP`, `X-Forwarded-For` y `X-Forwarded-Proto`, que le informan a la aplicación web Flask (a través de Gunicorn) la identidad del cliente original y que la solicitud provino de una conexión segura, previniendo fallos en esquemas de redirección y seguridad propios de Flask.

## Pasos para el Despliegue en Instancia AWS EC2

Para desplegar la aplicación PIA-LARA en una instancia de Amazon EC2, deben seguirse estos pasos estructurados:

1.  **Creación de la Instancia EC2**: 
    - Lanza una instancia desde el panel de AWS (se recomienda Ubuntu Server 22.04 LTS o posterior).
    - Configura el **Security Group** asociado para permitir tráfico entrante por los puertos **80** (HTTP), **443** (HTTPS) y **22** (SSH).

2.  **Conexión al Servidor**: 
    - Conéctate a tu instancia mediante SSH utilizando la clave descargada (`.pem`):
      ```bash
      ssh -i "tu_clave.pem" ubuntu@<IP_PUBLICA_EC2>
      ```

3.  **Instalación de Dependencias**:
    - Actualiza los repositorios e instala Docker y el plugin de Docker Compose:
      ```bash
      sudo apt-get update
      sudo apt-get install -y docker.io docker-compose-v2 git
      ```
    - (Opcional) Agrega tu usuario al grupo docker para ejecutar sin `sudo`:
      ```bash
      sudo usermod -aG docker ubuntu
      ```

4.  **Descarga del Proyecto**:
    - Clona el repositorio del proyecto PIA-LARA o sube los archivos de despliegue mediante SFTP/SCP.
      ```bash
      git clone <URL_DEL_REPOSITORIO> pialara
      cd pialara/pia-lara
      ```

5.  **Configuración de Variables de Producción**:
    - Crea el archivo `.ini` de producción a partir de la plantilla:
      ```bash
      cp produccion.ini.template produccion.ini
      ```
    - Modifica `produccion.ini` con las credenciales correspondientes a tu entorno de producción. Esta configuración será mapeada automáticamente al contenedor `web`.

6.  **Despliegue con Docker Compose**:
    - Una vez en el directorio que contiene el `docker-compose.yml`, construye las imágenes e inicia los servicios en segundo plano (`-d`):
      ```bash
      sudo docker compose up -d --build
      ```

7.  **Verificación**:
    - Accede desde un navegador a la IP pública de tu instancia AWS (ej. `https://<IP_PUBLICA_EC2>`). 
    - El contenedor `cert-generator` habrá creado el certificado SSL automáticamente, Nginx redirigirá el tráfico HTTP a HTTPS, y la aplicación Flask estará corriendo, lista para usarse, respaldada por MongoDB.
