## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

  helm repo add grengojbo https://grengojbo.github.io/charts/


To install the <chart-name> chart:

    helm install <chart-name> grengojbo/<chart-name>

To uninstall the chart:

    helm delete <chart-name>

### For Chart Developer

change files: 

  - charts/*/templates/18-letsencrypt-prod.yaml
  - charts/*/templates/ingress.yaml
  - charts/odoo/templates/svc.yaml
  - charts/{opencart,wordpress}/templates/svc.yaml (service http,https)

Download makesure

```bash
wget "https://raw.githubusercontent.com/xonixx/makesure/main/makesure?token=$(date +%s)" -Omakesure && \
chmod +x makesure && echo "makesure $(./makesure -v) installed"
```