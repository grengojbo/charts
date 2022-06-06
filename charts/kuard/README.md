# Kuard package

Demo app for Kubernetes Up

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add grengojbo https://grengojbo.github.io/charts/
```

To install the **kuard** chart:

```bash
helm upgrade -i kuard grengojbo/kuard -n default
```

To uninstall the chart:
```bash
helm delete kuard -n default
```
