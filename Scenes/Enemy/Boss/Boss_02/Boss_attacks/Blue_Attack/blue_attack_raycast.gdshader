shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Parameters to adjust the appearance of the gradient
    float maxIntensity = 1.0; // Maximum intensity in the center
    float fadeWidth = 0.9; // Width of the fade effect from center to edges

    // Calculate the distance from the center, normalized to the range [0, 0.5]
    float normalizedDistance = abs(UV.x - 0.1);

    // Calculate the alpha based on distance, creating a gradient that peaks at the center
    float alpha = 1.0 - smoothstep(0.0, fadeWidth, normalizedDistance);

    // Apply the calculated alpha to the color
    COLOR = vec4(0.1, 1.0, 1.0, alpha); // Example: Red color with gradient alpha
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

