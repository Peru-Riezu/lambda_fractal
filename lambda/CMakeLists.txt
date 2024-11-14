cmake_minimum_required(VERSION 3.16)
project(mandelbrot)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Ofast -flto")

set(aws-lambda-runtime_DIR "/usr/local/lib/aws-lambda-runtime/cmake/")

find_package(aws-lambda-runtime REQUIRED)
find_package(nlohmann_json REQUIRED)

set(SOURCE_FILES mandelbrot.cpp colors.hpp)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

target_link_libraries(${PROJECT_NAME} PRIVATE AWS::aws-lambda-runtime nlohmann_json mpfr)

aws_lambda_package_target(${PROJECT_NAME})

