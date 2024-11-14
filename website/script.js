const baseUrl = "https://x8v52b4gc0.execute-api.us-east-1.amazonaws.com/v1/mandelbrot?x=-1&y=0&scale=1.5&color_scheme=1";

const canvas = document.getElementById("pixelCanvas");
const ctx = canvas.getContext("2d");

// Array to hold the fetch promises along with their line numbers
const fetchPromises = [];

// Start all fetch requests and store the promises
for (let line = 1; line <= 1000; line++) {
    const url = `${baseUrl}&line=${line}`;
    const fetchPromise = fetch(url, { mode: 'cors' });
    fetchPromises.push({ line, fetchPromise });
}

// After all requests have been sent, process the responses
setTimeout(() => {
    // Shuffle the array to randomize the processing order
    fetchPromises.sort(() => Math.random() - 0.5);

    // Process each response as it resolves
    fetchPromises.forEach(({ line, fetchPromise }) => {
        fetchPromise
            .then(response => {
                if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
                return response.json();
            })
            .then(data => {
                if (!data || !Array.isArray(data.line_pixels)) {
                    throw new Error("Invalid data format received");
                }

                const pixels = data.line_pixels;

                // Draw the pixels for the current line on the canvas
                for (let x = 0; x < pixels.length; x++) {
                    const [r, g, b] = pixels[x];
                    ctx.fillStyle = `rgb(${r}, ${g}, ${b})`;
                    ctx.fillRect(x, line - 1, 1, 1); // Draw pixel at (x, line-1)
                }

                console.log(`Line ${line} drawn successfully!`);
            })
            .catch(error => {
                console.error(`Error fetching or drawing line ${line}:`, error);
            });
    });
}, 0); // Set timeout to 0 to ensure this runs after the main execution stack

