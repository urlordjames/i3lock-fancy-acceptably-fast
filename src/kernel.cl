__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;
// sigma = (17/2pi)
__constant float gauss[] = {0.0018629616, 0.0051897927, 0.012611598, 0.026734004, 0.049434684, 0.07973947, 0.11219893, 0.13771395, 0.14744873, 0.13771395, 0.11219893, 0.07973947, 0.049434684, 0.026734004, 0.012611598, 0.0051897927, 0.0018629616};

__kernel void box_blur_x(read_only image2d_t img_in, write_only image2d_t out_img) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0f, 0.0f, 0.0f, 0.0f);

	for (int i = -8; i <= 8; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(i, 0));
		pixel += sample * gauss[i + 8];
	}

	write_imagef(out_img, pos, pixel);
}

__kernel void box_blur_y(read_only image2d_t img_in, write_only image2d_t out_img) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0f, 0.0f, 0.0f, 0.0f);

	for (int i = -8; i <= 8; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(0, i));
		pixel += sample * gauss[i + 8];
	}

	write_imagef(out_img, pos, pixel);
}
