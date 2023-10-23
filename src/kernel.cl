__constant sampler_t sampler = CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST;
__constant float sqr = 17.0 * 17.0;

__kernel void box_blur(read_only image2d_t img_in, write_only image2d_t out_img) {
	int2 pos = (int2)(get_global_id(0), get_global_id(1));

	float4 pixel = (float4)(0.0, 0.0, 0.0, 0.0);

	for (int i = -8; i <= 8; i++) {
		for (int j = -8; j <= 8; j++) {
			float4 sample = read_imagef(img_in, sampler, pos + (int2)(i, j));
			pixel += sample;
		}
	}

	pixel /= (float4)(sqr, sqr, sqr, sqr);

	write_imagef(out_img, pos, pixel);
}
