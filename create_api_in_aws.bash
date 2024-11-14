aws apigateway create-rest-api --name "mandelbrot_api"

API_ID=$(aws apigateway get-rest-apis --query "items[?name=='mandelbrot_api'].id" --output text)

ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --query "items[?path=='/'].id" \
  --output text)

MANDELBROT_RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_RESOURCE_ID \
  --path-part "mandelbrot" \
  --query "id" --output text)

aws apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method GET \
  --authorization-type "NONE"

aws apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method GET \
  --integration-http-method POST \
  --type AWS \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:$(aws sts get-caller-identity --query "Account" --output text):function:mandelbrot/invocations \
  --request-templates "$(cat <<EOF
{
  "application/json": "{ \"queryStringParameters\": { \"x\": \"\$input.params('x')\", \"y\": \"\$input.params('y')\", \"scale\": \"\$input.params('scale')\", \"line\": \"\$input.params('line')\", \"color_scheme\": \"\$input.params('color_scheme')\" } }"
}
EOF
)"

aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method GET \
  --status-code 200

aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method GET \
  --status-code 200 \
  --response-parameters "method.response.header.Access-Control-Allow-Origin"="'*'"

aws apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method OPTIONS \
  --authorization-type "NONE"

aws apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method OPTIONS \
  --type MOCK \
  --request-templates '{"application/json": "{\"statusCode\": 200}"}'

aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method OPTIONS \
  --status-code 200 \
  --response-parameters \
    method.response.header.Access-Control-Allow-Headers=false,\
    method.response.header.Access-Control-Allow-Methods=false,\
    method.response.header.Access-Control-Allow-Origin=false

aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --resource-id $MANDELBROT_RESOURCE_ID \
  --http-method OPTIONS \
  --status-code 200 \
  --response-templates '{"application/json": ""}' \
  --response-parameters \
    method.response.header.Access-Control-Allow-Headers="'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",\
    method.response.header.Access-Control-Allow-Methods="'GET,OPTIONS'",\
    method.response.header.Access-Control-Allow-Origin="'*'"

aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name v1

#may need to give permissions to the lambda function
