__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;
// sigma = (21/2pi)
__constant float gauss[] = {0.0013581997, 0.0031791131, 0.0068040923, 0.013315463, 0.023826715, 0.038984675, 0.058323763, 0.07978459, 0.09979629, 0.11413835, 0.119363256, 0.11413835, 0.09979629, 0.07978459, 0.058323763, 0.038984675, 0.023826715, 0.013315463, 0.0068040923, 0.0031791131, 0.0013581997};

__kernel void box_blur_x(read_only image2d_t img_in, write_only image2d_t img_out) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0f, 0.0f, 0.0f, 0.0f);

	for (int i = -10; i <= 10; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(i, 0));
		pixel += sample * gauss[i + 10];
	}

	write_imagef(img_out, pos, pixel);
}

__kernel void box_blur_y(write_only image2d_t img_out, read_only image2d_t img_in) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0f, 0.0f, 0.0f, 0.0f);

	for (int i = -10; i <= 10; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(0, i));
		pixel += sample * gauss[i + 10];
	}

	write_imagef(img_out, pos, pixel);
}
