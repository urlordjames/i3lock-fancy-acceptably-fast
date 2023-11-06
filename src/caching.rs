const KERNEL_SRC: &str = include_str!("kernel.cl");
const KERNEL_VERSION: &str = "1";

pub fn get_program_cached(device: ocl::Device, ctx: &ocl::Context) -> ocl::Program {
	let home = std::path::PathBuf::from(std::env::var("HOME").unwrap());
	let cache_dir = home.join(".cache").join("i3lock-faf");
	std::fs::create_dir_all(&cache_dir).unwrap();

	let cache_version = cache_dir.join("version.txt");
	let version = std::fs::read_to_string(&cache_version).unwrap_or(String::from("0"));

	let cache_file = cache_dir.join("kernel.bin");
	std::fs::read(&cache_file).ok().and_then(|binary| {
		if KERNEL_VERSION != version { return None; }

		ocl::Program::builder()
			.binaries(&[&binary])
			.devices(device)
			.build(ctx).ok()
	}).unwrap_or_else(|| {
		let program = ocl::Program::builder()
			.src(KERNEL_SRC)
			.devices(device)
			.build(ctx).unwrap();

		match program.info(ocl::enums::ProgramInfo::Binaries).unwrap() {
			ocl::enums::ProgramInfoResult::Binaries(mut bins) => {
				let bin = bins.pop().unwrap();
				if bins.pop().is_some() { panic!("a single device should only produce one binary"); }
				std::fs::write(cache_file, bin).unwrap();
				std::fs::write(cache_version, KERNEL_VERSION).unwrap();
			},
			_ => unreachable!("not very rusty, but I'll work with it")
		}

		program
	})
}
