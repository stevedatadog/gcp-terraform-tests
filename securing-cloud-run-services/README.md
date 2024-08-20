This is the code from [Securing Cloud Run services
tutorial](https://cloud.google.com/run/docs/tutorials/secure-services)

The markdown-preview directory was copied from [GCP's Python Docs Samples
repository](git clone
https://github.com/GoogleCloudPlatform/python-docs-samples.git)

The GCP CLI instructions to deploy this two-service Cloud Run application are:

```sh
# variables
export GCP_PROJECT_ID=datadog-community
export GCP_PROJECT_NUMBER=$( \
  gcloud projects describe $GCP_PROJECT_ID \
  --format='value(projectNumber)' \
  )
export GCP_REGION=us-west2
export GCP_LABEL_OWNER=steve-calnan
export GCP_LABEL_TEAM=training

# The renderer
cd markdown-preview/renderer
gcloud artifacts repositories create markdown-preview \
  --repository-format docker \
  --location $GCP_REGION \
  --labels=owner=$GCP_LABEL_OWNER,team=$GCP_LABEL_TEAM
gcloud builds submit \
  --tag $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/markdown-preview/renderer
gcloud iam service-accounts create renderer-identity \
  --display-name="markdown-preview renderer SA" \
  --description="owner:$GCP_LABEL_OWNER"
gcloud run deploy renderer \
  --image $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/markdown-preview/renderer \
  --service-account renderer-identity \
  --no-allow-unauthenticated \
  --labels=owner=$GCP_LABEL_OWNER,team=$GCP_LABEL_TEAM

# Test the private service
gcloud run services list
TOKEN=$(gcloud auth print-identity-token)
curl -H "Authorization: Bearer $TOKEN" \
   -H 'Content-Type: text/plain' \
   -d '**Hello Bold Text**' \
   https://renderer-$GCP_PROJECT_NUMBER.$GCP_REGION.run.app

# The editor
cd ../renderer
gcloud builds submit \
  --tag $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/markdown-preview/editor
gcloud iam service-accounts create editor-identity \
  --display-name="markdown-preview editor SA" \
  --description="owner:$GCP_LABEL_OWNER"
gcloud run services add-iam-policy-binding renderer \
  --member serviceAccount:editor-identity@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/run.invoker
gcloud run deploy editor \
  --image $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/markdown-preview/editor \
  --service-account editor-identity \
  --set-env-vars EDITOR_UPSTREAM_RENDER_URL=https://renderer-$GCP_PROJECT_NUMBER.$GCP_REGION.run.app \
  --allow-unauthenticated \
  --labels=owner=$GCP_LABEL_OWNER,team=$GCP_LABEL_TEAM
```

The Terrafrom scripts to do the above are in `markdown-preview/terraform`


