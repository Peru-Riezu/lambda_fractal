#include "./colors.hpp"
#include <aws/lambda-runtime/runtime.h>
#include <cmath>
#include <cstddef>
#include <mpreal.h>
#include <nlohmann/json.hpp>
#include <string>
#include <utility>
#include <vector>

mpfr::mpreal linear_interpolate(unsigned char a, unsigned char b, mpfr::mpreal &t)
{
	return ((((mpfr::mpreal(1.0) - t) * mpfr::mpreal(a)) + (t * mpfr::mpreal(b))));
}

mpfr::mpreal get_iterations(mpfr::mpreal &x, mpfr::mpreal &y, int max_iterations)
{
	mpfr::mpreal const escape_radius = 4.0;
	mpfr::mpreal const escape_radius_squared = escape_radius * escape_radius;
	mpfr::mpreal       z_real = 0.0;
	mpfr::mpreal       z_imag = 0.0;
	int                iterations = 0;

	while (iterations < max_iterations)
	{
		mpfr::mpreal z_real_squared = z_real * z_real;
		mpfr::mpreal z_imag_squared = z_imag * z_imag;
		if (z_real_squared + z_imag_squared > escape_radius_squared)
		{
			break;
		}
		mpfr::mpreal new_z_imag = 2.0 * z_real * z_imag + y;
		z_real = z_real_squared - z_imag_squared + x;
		z_imag = new_z_imag;
		iterations++;
	}
	if (iterations == max_iterations)
	{
		return max_iterations;
	}
	mpfr::mpreal value = z_real * z_real + z_imag * z_imag;
	mpfr::mpreal normalizer = (1 - mpfr::exp(-.37 * (value / (escape_radius * escape_radius) - 1)));
	return (iterations - normalizer);
}

s_high_precision_color get_pixel(mpfr::mpreal &x, mpfr::mpreal &y, int color_scheme_number)
{
	int const             max_iterations = 420;
	mpfr::mpreal          iterations = get_iterations(x, y, max_iterations);
	std::vector<s_color> &colors = colorschemes[color_scheme_number];
	size_t                num_colors = colors.size();
	mpfr::mpreal          res;
	size_t                index_floor = static_cast<int>(static_cast<int>(mpfr::floor(iterations)) % num_colors);
	size_t                index_ceil = (index_floor + 1) % num_colors;
	mpfr::mpreal          fraction = mpfr::fmod(iterations, 1.0);
	mpfr::mpreal          r =
		static_cast<unsigned char>(linear_interpolate(colors[index_floor].r, colors[index_ceil].r, fraction));
	mpfr::mpreal g =
		static_cast<unsigned char>(linear_interpolate(colors[index_floor].g, colors[index_ceil].g, fraction));
	mpfr::mpreal b =
		static_cast<unsigned char>(linear_interpolate(colors[index_floor].b, colors[index_ceil].b, fraction));

	if (iterations >= max_iterations)
	{
		return {0, 0, 0};
	}
	return (s_high_precision_color{r, g, b});
}

//NOLINTNEXTLINE
unsigned char clamp(mpfr::mpreal x)
{
	x = mpfr::rint_round(x);
	if (x > 255)
	{
		return (255);
	}
	return (static_cast<unsigned char>(x.toULong()));
}

std::vector<unsigned char> get_anti_aliased_pixel(mpfr::mpreal &x, mpfr::mpreal &y, mpfr::mpreal &delta_of_x,
												   int color_scheme_number)
{
	std::vector<std::pair<mpfr::mpreal, mpfr::mpreal>> offsets = {
		{			  0,			   0},
		{			  0,  delta_of_x / 3},
		{			  0, -delta_of_x / 3},

		{ delta_of_x / 3,               0},
		{ delta_of_x / 3,  delta_of_x / 3},
		{ delta_of_x / 3, -delta_of_x / 3},

		{-delta_of_x / 3,               0},
		{-delta_of_x / 3,  delta_of_x / 3},
		{-delta_of_x / 3, -delta_of_x / 3},
	};
	mpfr::mpreal sum_r = 0;
	mpfr::mpreal sum_g = 0;
	mpfr::mpreal sum_b = 0;

	for (size_t i = 0; i < offsets.size(); i++)
	{
		mpfr::mpreal x_prima = x + offsets[i].first;
		mpfr::mpreal y_prima = y + offsets[i].second;
		s_high_precision_color pixel = get_pixel(x_prima, y_prima, color_scheme_number);
		sum_r += pixel.r;
		sum_g += pixel.g;
		sum_b += pixel.b;
	}
	sum_r /= offsets.size();
	sum_g /= offsets.size();
	sum_b /= offsets.size();
	return {clamp(sum_r),
			clamp(sum_g),
			clamp(sum_b)};
}

aws::lambda_runtime::invocation_response my_handler(aws::lambda_runtime::invocation_request const &req)
{
	try
	{
		nlohmann::json event = nlohmann::json::parse(req.payload);
		mpfr::mpreal::set_default_prec(1024);
		mpfr::mpreal::set_default_rnd(MPFR_RNDA);
		nlohmann::json query_params = event["queryStringParameters"];
		mpfr::mpreal x = std::stod(query_params["x"].get<std::string>());
		mpfr::mpreal y = std::stod(query_params["y"].get<std::string>());
		mpfr::mpreal scale = std::stod(query_params["scale"].get<std::string>());
		int          line_number = std::stoi(query_params["line"].get<std::string>());
		size_t color_scheme_number = std::stoi(query_params["color_scheme"].get<std::string>()) % colorschemes.size();

		mpfr::mpreal delta_of_x = scale * 2 / 1000;
		y += ((325 - line_number) * delta_of_x);
		x -= scale;
		std::vector<std::vector<unsigned char>> line_pixels(1000);
		for (int i = 0; i < 1000; ++i)
		{
			line_pixels[i] = get_anti_aliased_pixel(x, y, delta_of_x, static_cast<int>(color_scheme_number));
			x += delta_of_x;
		}
		nlohmann::json response_body = nlohmann::json{
			{"line_pixels", line_pixels}
        };
		return (aws::lambda_runtime::invocation_response::success(response_body.dump(), "application/json"));
	}
	catch (std::exception const &e)
	{
		return (aws::lambda_runtime::invocation_response::failure(e.what(), "application/json"));
	}
}

//	g++ -fsanitize=address,undefined,leak mandelbrot.cpp -lmpfr -laws-lambda-runtime -lcurl
//		std::cout << response_body.dump();
//	aws::lambda_runtime::invocation_request req{"{\"queryStringParameters\":{\"x\":\"1.3\",\"y\":\"0\",\"scale\":\"1\","
//												"\"line\":\"1\",\"color_scheme\":\"1\" }}"};
//	my_handler(req);
int main(int __attribute__((unused)) argc, char __attribute__((unused)) * argv[])
{
	run_handler(my_handler);
	return (0);
}
