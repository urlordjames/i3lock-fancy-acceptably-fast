__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;
__constant int radius = 15;
// sigma = (31/2pi)
__constant float gauss[] = {0.0007954424, 0.0014431258, 0.0025128035, 0.004199251, 0.0067351, 0.010367528, 0.0153167015, 0.021717722, 0.029554406, 0.03860016, 0.04838547, 0.058210287, 0.06721148, 0.0744811, 0.07921505, 0.080858976, 0.07921505, 0.0744811, 0.06721148, 0.058210287, 0.04838547, 0.03860016, 0.029554406, 0.021717722, 0.0153167015, 0.010367528, 0.0067351, 0.004199251, 0.0025128035, 0.0014431258, 0.0007954424};

__kernel void gauss_blur_x(read_only image2d_t img_in, write_only image2d_t img_out) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = 0.0f;

	for (int i = -radius; i <= radius; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(i, 0));
		pixel += sample * gauss[i + radius];
	}

	write_imagef(img_out, pos, pixel);
}

__kernel void gauss_blur_y(write_only image2d_t img_out, read_only image2d_t img_in) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = 0.0f;

	for (int i = -radius; i <= radius; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(0, i));
		pixel += sample * gauss[i + radius];
	}

	write_imagef(img_out, pos, pixel);
}
