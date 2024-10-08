use xcb::x;
use std::io::Write;

mod caching;
use caching::get_program_cached;

fn main() {
	let (conn, screen_num) = xcb::Connection::connect(None).unwrap();
	let setup = conn.get_setup();
	let screen = setup.roots().nth(screen_num as usize).unwrap();

	let (width, height) = (screen.width_in_pixels(), screen.height_in_pixels());

	let cookie = conn.send_request(&x::GetImage {
		format: x::ImageFormat::ZPixmap,
		drawable: x::Drawable::Window(screen.root()),
		x: 0,
		y: 0,
		width,
		height,
		plane_mask: u32::MAX
	});

	let ctx = ocl::Context::builder()
		.devices(ocl::Device::specifier().first())
		.build().unwrap();
	let device = ctx.devices()[0];
	let queue = ocl::Queue::new(&ctx, device, None).unwrap();

	let program = get_program_cached(device, &ctx);

	let img_dims = ocl::SpatialDims::Two(width as usize, height as usize);

	let reply = conn.wait_for_reply(cookie).unwrap();
	let screen = reply.data();

	let img_flags = ocl::flags::MEM_READ_WRITE | ocl::flags::MEM_HOST_READ_ONLY;

	let img_in = ocl::Image::<u8>::builder()
		.channel_order(ocl::enums::ImageChannelOrder::Bgra)
		.channel_data_type(ocl::enums::ImageChannelDataType::UnormInt8)
		.image_type(ocl::enums::MemObjectType::Image2d)
		.dims(img_dims)
		.flags(img_flags)
		.queue(queue.clone())
		.copy_host_slice(screen)
		.build().unwrap();

	let img_out = ocl::Image::<u8>::builder()
		.channel_order(ocl::enums::ImageChannelOrder::Bgra)
		.channel_data_type(ocl::enums::ImageChannelDataType::UnormInt8)
		.image_type(ocl::enums::MemObjectType::Image2d)
		.dims(img_dims)
		.flags(img_flags)
		.queue(queue.clone())
		.build().unwrap();

	for program_name in ["gauss_blur_x", "gauss_blur_y"] {
		let mut kernel_builder = ocl::Kernel::builder();
		kernel_builder.program(&program);
		kernel_builder.name(program_name);
		kernel_builder.queue(queue.clone());
		kernel_builder.global_work_size(img_dims);
		kernel_builder.arg(&img_in);
		kernel_builder.arg(&img_out);

		let kernel = kernel_builder.build().unwrap();
		unsafe {
			kernel.enq().unwrap();
		}
	}

	let mut img = vec![0; width as usize * height as usize * 4];
	img_in.read(&mut img).enq().unwrap();
	queue.finish().unwrap();

	let mut i3lock = std::process::Command::new("i3lock")
		.args(["--raw=1920x1080:bgrx", "--image", "/dev/stdin", "-f", "--nofork"])
		.stdin(std::process::Stdio::piped())
		.spawn().unwrap();
	let i3lock_stdin = i3lock.stdin.as_mut().unwrap();
	i3lock_stdin.write_all(&img).unwrap();
	i3lock.wait().unwrap();
}
