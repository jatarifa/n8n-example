# n8n Docker Setup

## Inicio rápido

```bash
cd docker && ./start.sh
```

Accede a n8n en: http://localhost:5678

## Credenciales de acceso

**Email:** admin@localhost.com
**Password:** Admin123456

## Estructura

```
.
├── README.md                         # Este archivo
├── CLAUDE.md                         # Quick reference para Claude Code
├── INSTALL_MCP.md                    # Instrucciones para instalar el MCP de n8n
├── WORKFLOW_LOGS_ANALYZER.md         # Especificación del workflow Logs Analyzer
├── GEMINI_API_KEY_SETUP.md           # Cómo obtener y configurar Gemini API key
├── mm-provision-osp-sta-*.json       # Credenciales de GCP Service Account (not included in repository)
├── docker/
│   ├── .env                          # Configuración local (git-ignored)
│   ├── .env.example                  # Plantilla de configuración
│   ├── .gitignore                    # Excluye data/ y .env
│   ├── docker-compose.yml            # Configuración de Docker
│   ├── start.sh                      # Levantar n8n
│   ├── stop.sh                       # Detener n8n
│   └── data/                         # Datos persistentes (workflows, credentials, DB)
└── flow/
    ├── README.md                     # Descripción de workflows exportados
    └── logs-analyzer.json            # Workflow Logs Analyzer exportado
```

## Comandos útiles

```bash
# Levantar n8n
cd docker && ./start.sh

# Detener n8n
cd docker && ./stop.sh

# Ver logs en tiempo real
cd docker && docker compose logs -f

# Reiniciar
cd docker && docker compose restart

# Ver estado del contenedor
docker ps --filter name=n8n
```

## Configuración

El archivo `.env` se crea automáticamente desde `.env.example` al ejecutar el script `start.sh`.

**⚠️ IMPORTANTE - Configurar API Keys:**
Antes de usar el workflow "Logs Analyzer", debes configurar las siguientes API keys en el archivo `docker/.env`:

```bash
# Copia el ejemplo
cp docker/.env.example docker/.env

# Edita y añade tus API keys
GEMINI_API_KEY=tu_api_key_de_gemini
SLACK_BOT_TOKEN=tu_token_de_slack
```

Variables disponibles:
- `N8N_HOST`: Hostname (default: localhost)
- `N8N_PROTOCOL`: http o https (default: http)
- `WEBHOOK_URL`: URL para webhooks (default: http://localhost:5678/)
- `TIMEZONE`: Zona horaria (default: Europe/Madrid)
- `GEMINI_API_KEY`: API key de Google Gemini (ver `GEMINI_API_KEY_SETUP.md`)
- `SLACK_BOT_TOKEN`: Token del bot de Slack

## Datos persistentes

Todos los datos de n8n se almacenan en el directorio `docker/data/`:
- `database.sqlite`: Base de datos SQLite
- `workflows/`: Workflows guardados
- `credentials/`: Credenciales cifradas
- `config`: Configuración de n8n

## API de n8n

La API está disponible en: http://localhost:5678/api/v1/

**Gestión de API Keys:**
1. Accede a http://localhost:5678/settings/api
2. Crea o gestiona tus API keys (necesarias para usar el MCP)
3. API Playground: http://localhost:5678/api/v1/docs

Ver `INSTALL_MCP.md` para instrucciones de instalación del MCP.

## Workflows

Este proyecto incluye workflows preconfigurados en el directorio `flow/`:

**Logs Analyzer** (`flow/logs-analyzer.json`)
- Comando Slack `/logs` para analizar logs de BigQuery con IA
- Análisis automático usando Google Gemini
- Crea canales Slack dedicados para cada análisis
- Ver especificación completa en `WORKFLOW_LOGS_ANALYZER.md`

Para importar workflows:
1. Accede a http://localhost:5678
2. Click en menú → Import from File
3. Selecciona el archivo JSON del workflow

## Versión

- n8n: latest
- Puerto: 5678

## Troubleshooting

**Container no inicia:**
```bash
cd docker && docker compose logs n8n
```

**Resetear completamente:**
```bash
cd docker
./stop.sh
rm -rf data/
./start.sh
```

**Verificar estado:**
```bash
docker ps --filter name=n8n
```
