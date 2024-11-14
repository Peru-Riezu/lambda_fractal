#!/bin/bash

# Create the REST API
echo "Creating API Gateway..."
aws apigateway create-rest-api --name "mandelbrot_api"

# Retrieve the API ID
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='mandelbrot_api'].id" --output text)
echo "API ID: $API_ID"

# Get the root resource ID
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query "items[?path=='/'].id" \
  --output text)
echo "Root Resource ID: $ROOT_RESOURCE_ID"

# Create the /mandelbrot resource
MANDELBROT_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id "$API_ID" \
  --parent-id "$ROOT_RESOURCE_ID" \
  --path-part "mandelbrot" \
  --query "id" --output text)
echo "Mandelbrot Resource ID: $MANDELBROT_RESOURCE_ID"

# Create the GET method
echo "Creating GET method..."
aws apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method GET \
  --authorization-type "NONE"

# Set up the integration for GET
echo "Setting up GET integration..."
aws apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method GET \
  --integration-http-method POST \
  --type AWS \
  --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:$(aws sts get-caller-identity --query "Account" --output text):function:mandelbrot/invocations" \
  --request-templates "$(cat <<EOF
{
  "application/json": "{ \"queryStringParameters\": { \"x\": \"\$input.params('x')\", \"y\": \"\$input.params('y')\", \"scale\": \"\$input.params('scale')\", \"line\": \"\$input.params('line')\", \"color_scheme\": \"\$input.params('color_scheme')\" } }"
}
EOF
)"

# Create the method response for GET
echo "Setting up GET method response..."
aws apigateway put-method-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method GET \
  --status-code 200 \

# Create the integration response for GET
echo "Setting up GET integration response..."
aws apigateway put-integration-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method GET \
  --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Origin": "*"}'

# Create the OPTIONS method for CORS preflight
echo "Creating OPTIONS method..."
aws apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --authorization-type "NONE"

# Set up the MOCK integration for OPTIONS
echo "Setting up OPTIONS integration..."
aws apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --type MOCK \
  --request-templates '{"application/json": "{\"statusCode\": 200}"}'

# Create the method response for OPTIONS
echo "Setting up OPTIONS method response..."
aws apigateway put-method-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Headers": false, "method.response.header.Access-Control-Allow-Methods": false, "method.response.header.Access-Control-Allow-Origin": false}'

# Create the integration response for OPTIONS with CORS headers
echo "Setting up OPTIONS integration response..."
aws apigateway put-integration-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --status-code 200 \
  --response-templates '{"application/json": ""}' \
  --response-parameters '{"method.response.header.Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token", "method.response.header.Access-Control-Allow-Methods": "GET,OPTIONS", "method.response.header.Access-Control-Allow-Origin": "*"}'

# Deploy the API
echo "Deploying API..."
aws apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name v1
echo "API deployed successfully."

