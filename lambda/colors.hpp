#pragma once

#include <vector>

struct s_color
{
		unsigned char r;
		unsigned char g;
		unsigned char b;
};

static std::vector<std::vector<s_color>> colorschemes = {
	{
     {66, 30, 15}, // Dark Brown
 {25, 7, 26}, // Deep Purple
 {9, 1, 47}, // Dark Blue
 {4, 4, 73}, // Blue
 {0, 7, 100}, // Medium Blue
 {12, 44, 138}, // Lighter Blue
 {24, 82, 177}, // Even Lighter Blue
 {57, 125, 209}, // Light Blue
 {134, 181, 229}, // Sky Blue
 {211, 236, 248}, // Very Light Blue
 {241, 233, 191}, // Light Yellow
 {248, 201, 95}, // Yellow
 {255, 170, 0}, // Orange
 {204, 128, 0}, // Dark Orange
 {153, 87, 0}, // Brown
 {106, 52, 3}, // Darker Brown
 {50, 28, 11}, // Deep Brown
 {0, 0, 0}, // Black
 {0, 43, 54}, // Midnight Blue
 {0, 57, 78}, // Deep Sea Blue
 {0, 77, 102}, // Teal Blue
 {0, 109, 132}, // Turquoise
 {0, 146, 152}, // Ocean Green
 {0, 173, 165}, // Sea Green
 {0, 202, 171}, // Greenish Cyan
 {64, 224, 208}, // Turquoise
 {127, 255, 212}, // Aquamarine
 {143, 188, 143}, // Dark Sea Green
 {107, 142, 35}, // Olive Green
 {85, 107, 47}, // Dark Olive Green
 {128, 128, 0}, // Olive
 {173, 255, 47}, // Green Yellow
 {202, 255, 112}, // Light Green Yellow
 {255, 255, 224}, // Light Yellow
 {255, 250, 205}, // Lemon Chiffon
 {255, 239, 219}, // Papaya Whip
 {255, 228, 225}, // Misty Rose
 {255, 192, 203}, // Pink
 {255, 105, 180}, // Hot Pink
 {255, 20, 147}, // Deep Pink
 {199, 21, 133}, // Medium Violet Red
 {139, 0, 139}, // Dark Magenta
 {75, 0, 130}, // Indigo
 {72, 61, 139}, // Dark Slate Blue
 {106, 90, 205}, // Slate Blue
 {123, 104, 238}, // Medium Slate Blue
 {147, 112, 219}, // Medium Purple
 {186, 85, 211}, // Medium Orchid
 {221, 160, 221}, // Plum
 {238, 130, 238}  // Violet
	}
};
