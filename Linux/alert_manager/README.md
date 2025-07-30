# Alert Manager Setup with Prometheus and cAdvisor

This setup provides a monitoring solution using Prometheus, AlertManager, and cAdvisor for container monitoring.

## Components

- **Prometheus**: Monitoring system and time series database
- **AlertManager**: Handles alerts sent by Prometheus
- **cAdvisor**: Analyzes resource usage and performance characteristics of running containers

## Ports

- Prometheus: http://localhost:9090
- AlertManager: http://localhost:9093
- cAdvisor: http://localhost:8080

## Directory Structure

```
alert_manager/
├── docker-compose.yml
├── prometheus/
│   ├── prometheus.yml
│   └── alert.rules.yml
└── alertmanager/
    └── config.yml
```

## Usage

1. Start the services:
   ```bash
   docker-compose up -d
   ```

2. Access the services:
   - Prometheus UI: http://localhost:9090
   - AlertManager UI: http://localhost:9093
   - cAdvisor UI: http://localhost:8080

3. View alerts in Prometheus:
   - Go to http://localhost:9090/alerts

## Configured Alerts

1. **HighCPUUsage**
   - Triggers when container CPU usage is above 80% for 5 minutes
   - Severity: warning

2. **HighMemoryUsage**
   - Triggers when container memory usage is above 80% for 5 minutes
   - Severity: warning

3. **ContainerDown**
   - Triggers when a container has been down for 5 minutes
   - Severity: critical

## Customization

- Modify `prometheus/alert.rules.yml` to adjust alert conditions
- Modify `alertmanager/config.yml` to configure notification settings
- Modify `prometheus/prometheus.yml` to adjust scraping intervals or add new targets