# Create the REST API
aws apigateway create-rest-api --name "mandelbrot_api"

# Retrieve the API ID
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='mandelbrot_api'].id" --output text)

# Get the root resource ID
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query "items[?path=='/'].id" \
  --output text)

# Create the /mandelbrot resource
MANDELBROT_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id "$API_ID" \
  --parent-id "$ROOT_RESOURCE_ID" \
  --path-part "mandelbrot" \
  --query "id" --output text)

# Create the GET method
aws apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method GET \
  --authorization-type "NONE"

# Set up the integration for GET
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
aws apigateway put-method-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method GET \
  --status-code 200

# Create the integration response for GET with corrected response parameters
aws apigateway put-integration-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method GET \
  --status-code 200 \
  --response-parameters "$(cat <<EOF
{
  "method.response.header.Access-Control-Allow-Origin": "'*'"
}
EOF
)"

# Create the OPTIONS method
aws apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --authorization-type "NONE"

# Set up the MOCK integration for OPTIONS
aws apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --type MOCK \
  --request-templates '{"application/json": "{\"statusCode\": 200}"}'

# Create the method response for OPTIONS with corrected response parameters
aws apigateway put-method-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Headers":false,"method.response.header.Access-Control-Allow-Methods":false,"method.response.header.Access-Control-Allow-Origin":false}'

# Create the integration response for OPTIONS with corrected response parameters
aws apigateway put-integration-response \
  --rest-api-id "$API_ID" \
  --resource-id "$MANDELBROT_RESOURCE_ID" \
  --http-method OPTIONS \
  --status-code 200 \
  --response-templates '{"application/json": ""}' \
  --response-parameters "{\"method.response.header.Access-Control-Allow-Headers\":\"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'\",\"method.response.header.Access-Control-Allow-Methods\":\"'GET,OPTIONS'\",\"method.response.header.Access-Control-Allow-Origin\":\"'*'\"}"

# Deploy the API
aws apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name v1

