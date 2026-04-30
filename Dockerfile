# Usamos una imagen base ligera de Python 3.9
FROM python:3.9-slim-buster

# Evitar la escritura de archivos .pyc y forzar logs sin buffer
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar dependencias y ejecutarlas
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copiar el código fuente
COPY . .

# Crear el directorio para audios locales
RUN mkdir -p /app/pialara/static/audios

# Exponer el puerto de Gunicorn
EXPOSE 8000

# Ejecutar la aplicación con Gunicorn
CMD ["gunicorn", "--workers=4", "--bind=0.0.0.0:8000", "pialara:create_app()"]
