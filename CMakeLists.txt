cmake_minimum_required(VERSION 3.16)
project(mandelbrot)

# Enable C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set AWS Lambda C++ Runtime path (adjust this if needed)
set(aws-lambda-runtime_DIR "/usr/local/lib/aws-lambda-runtime/cmake/")

# Include AWS Lambda C++ runtime
find_package(aws-lambda-runtime REQUIRED)
find_package(nlohmann_json REQUIRED)

# Source files
set(SOURCE_FILES mandelbrot.cpp colors.hpp)

# Define the AWS Lambda function
add_executable(${PROJECT_NAME} ${SOURCE_FILES})

# Link AWS Lambda runtime library
target_link_libraries(${PROJECT_NAME} PRIVATE AWS::aws-lambda-runtime nlohmann_json mpfr)

# Package the function for deployment
aws_lambda_package_target(${PROJECT_NAME})

