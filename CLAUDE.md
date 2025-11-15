# n8n Sandbox con MCP

Proyecto sandbox para experimentar con n8n usando el MCP (Model Context Protocol).

## Quick Start

1. **Configurar API keys (requerido para workflow Logs Analyzer):**
   ```bash
   cp docker/.env.example docker/.env
   # Editar docker/.env y añadir GEMINI_API_KEY y SLACK_BOT_TOKEN
   ```

2. **Iniciar n8n:**
   ```bash
   cd docker && ./start.sh
   ```

3. **Acceso:** http://localhost:5678
   - Email: admin@localhost.com
   - Password: Admin123456

4. **MCP instalado:** Ver `INSTALL_MCP.md` para detalles de instalación

## Uso del MCP

El MCP de n8n te permite:

**Consultas de documentación:**
- "Lista nodos disponibles de IA"
- "Muéstrame cómo usar el nodo HTTP Request"
- "Busca plantillas de workflows para Slack"

**Gestión de workflows (con API key):**
- "Crea un workflow simple que..."
- "Lista mis workflows existentes"
- "Ejecuta el workflow X"

## Workflows

**Logs Analyzer:**
- Especificación: `WORKFLOW_LOGS_ANALYZER.md`
- Exportado: `flow/logs-analyzer.json`
- ID en n8n: `pI5VIZDiGAataU0N`
- Versión: 111
- Nodos: 15 (con creación automática de canales Slack)
- Requiere: GEMINI_API_KEY y SLACK_BOT_TOKEN en `.env`

## Recursos

- **API Playground:** http://localhost:5678/api/v1/docs
- **Documentación detallada:** Ver `README.md`
- **MCP Info:** Ver `INSTALL_MCP.md`

## Datos locales

Todos los workflows y datos están en `docker/data/` (persistente).
