 aws lambda create-function --function-name mandelbrot --runtime provided.al2023 --role arn:aws:iam::$(aws sts get-caller-identity --query "Account" --output text):role/LabRole --architectures x86_64 --memory-size 2048 --zip-file fileb://lambda/build/mandelbrot.zip --handler mandelbrot --timeout 30

 aws lambda put-function-concurrency --function-name mandelbrot --reserved-concurrent-executions 100

