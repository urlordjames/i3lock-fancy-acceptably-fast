__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;
__constant float norm = 17.0;

__kernel void box_blur_x(read_only image2d_t img_in, write_only image2d_t out_img) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0, 0.0, 0.0, 0.0);

	for (int i = -8; i <= 8; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(i, 0));
		pixel += sample;
	}

	pixel /= (float4)(norm, norm, norm, norm);

	write_imagef(out_img, pos, pixel);
}

__kernel void box_blur_y(read_only image2d_t img_in, write_only image2d_t out_img) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0, 0.0, 0.0, 0.0);

	for (int i = -8; i <= 8; i++) {
		float4 sample = read_imagef(img_in, sampler, pos + (int2)(0, i));
		pixel += sample;
	}

	pixel /= (float4)(norm, norm, norm, norm);

	write_imagef(out_img, pos, pixel);
}
