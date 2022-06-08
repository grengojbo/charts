## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add grengojbo https://grengojbo.github.io/charts/
```

To install the **grafana-agent-cloud** chart:


```bash
helm repo update 
helm upgrade -i monitoring grengojbo/grafana-agent-cloud  -n monitoring --wait -f <path to secret value>/grafana-agent-value.yaml
```

To uninstall the chart:

```bash
    helm delete monitoring
```

[Image Tags](https://hub.docker.com/r/grafana/agent/tags)

## Dashboards

Kubernetes Nginx Ingress Prometheus NextGen

cert-manager
