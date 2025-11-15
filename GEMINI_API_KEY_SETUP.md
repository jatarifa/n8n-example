# Configuración de Gemini API Key

El workflow **Logs Analyzer** usa la API REST de Google Gemini directamente para analizar los logs.

## Paso 1: Obtener API Key de Google AI Studio

1. Ve a https://aistudio.google.com/app/apikey
2. Click en "Create API key"
3. Selecciona un proyecto de Google Cloud o crea uno nuevo
4. Copia la API key generada (formato: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`)

## Paso 2: Configurar variable de entorno en n8n

### Opción A: Via docker-compose.yml (Recomendado)

Edita `docker/docker-compose.yml` y añade la variable de entorno:

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - TZ=Europe/Madrid
      - GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  # <-- Añade esta línea
    volumes:
      - ./data:/home/node/.n8n
```

Luego reinicia n8n:
```bash
cd docker
./stop.sh
./start.sh
```

### Opción B: Via archivo .env

1. Crea archivo `docker/.env`:
```bash
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

2. Modifica `docker/docker-compose.yml` para usar el archivo .env:
```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - TZ=Europe/Madrid
      - GEMINI_API_KEY=${GEMINI_API_KEY}
    env_file:
      - .env
    volumes:
      - ./data:/home/node/.n8n
```

3. Reinicia n8n

### Opción C: Via UI de n8n

1. Accede a http://localhost:5678/settings/variables
2. Click en "Add variable"
3. Name: `GEMINI_API_KEY`
4. Value: Tu API key
5. Type: `String`
6. Click "Save"

**Nota**: La opción C requiere reiniciar workflows activos para que detecten la nueva variable.

## Verificar configuración

1. Accede al workflow en n8n UI
2. Abre el nodo "Call Gemini API"
3. Verifica que el query parameter `key` tenga el valor `={{ $env.GEMINI_API_KEY }}`
4. Ejecuta una prueba del workflow

## Modelo usado

El workflow usa el modelo **gemini-2.0-flash-exp** que ofrece:
- Soporte para prompts largos (hasta 2M tokens)
- Respuestas rápidas
- Gratuito hasta ciertos límites de uso

Puedes cambiar el modelo editando el nodo "Call Gemini API":
```
URL: https://generativelanguage.googleapis.com/v1beta/models/MODELO:generateContent
```

Modelos disponibles:
- `gemini-2.0-flash-exp` - Rápido y gratuito
- `gemini-1.5-pro` - Más potente
- `gemini-1.5-flash` - Balance velocidad/calidad

## Límites de uso (Free tier)

- 1,500 requests por día
- 1 millón de tokens de entrada por minuto
- 4,000 requests por minuto

Ver más: https://ai.google.dev/pricing
