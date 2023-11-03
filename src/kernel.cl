__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;
// sigma = (17/2pi)
__constant float gauss[] = {0.0018629616f, 0.0051897927f, 0.012611598f, 0.026734004f, 0.049434684f, 0.07973947f, 0.11219893f, 0.13771395f, 0.14744873f, 0.13771395f, 0.11219893f, 0.07973947f, 0.049434684f, 0.026734004f, 0.012611598f, 0.0051897927f, 0.0018629616f};

__kernel void box_blur_x(read_only image2d_t img_in, write_only image2d_t img_out) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0f, 0.0f, 0.0f, 0.0f);

	for (int i = -8; i <= 8; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(i, 0));
		pixel += sample * gauss[i + 8];
	}

	write_imagef(img_out, pos, pixel);
}

__kernel void box_blur_y(write_only image2d_t img_out, read_only image2d_t img_in) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0f, 0.0f, 0.0f, 0.0f);

	for (int i = -8; i <= 8; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(0, i));
		pixel += sample * gauss[i + 8];
	}

	write_imagef(img_out, pos, pixel);
}
