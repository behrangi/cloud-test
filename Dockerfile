name: Deploy Nginx

on:
  push:
    branches:
      - 'main'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:

      - name: code checkout
        uses: actions/checkout@v2

      - name: install the gcloud cli
        uses: google-github-actions/setup-gcloud@v0
        with:
          project_id: ${{ secrets.GOOGLE_PROJECT }}
          service_account_key: ${{ secrets.GOOGLE_APPLICATION_CREDENTIALS }}
          install_components: 'gke-gcloud-auth-plugin'
          export_default_credentials: true

      - name: build and push the docker image
        env:
          GOOGLE_PROJECT: ${{ secrets.GOOGLE_PROJECT }}
        run: |
          gcloud auth configure-docker us-central1-docker.pkg.dev
          docker build -t us-central1-docker.pkg.dev/$GOOGLE_PROJECT/demo/nginx:latest .
          docker push us-central1-docker.pkg.dev/$GOOGLE_PROJECT/demo/nginx:latest

      - name: deploy to gke
        env:
          GOOGLE_PROJECT: ${{ secrets.GOOGLE_PROJECT }}
        run: |
          gcloud container clusters get-credentials autopilot-cluster-1 --region us-central1
          sed -i "s/GOOGLE_PROJECT/$GOOGLE_PROJECT/g" resources.yaml
          kubectl apply -f resources.yaml