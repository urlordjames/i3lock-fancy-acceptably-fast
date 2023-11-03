fn main() {
	let gausses: Vec<f32> = (-10..=10).map(gauss).collect();
	println!("{gausses:?}");
}

const SIGMA: f32 = 21.0 / (2.0 * std::f32::consts::PI);
const VARIANCE: f32 = SIGMA * SIGMA;

fn gauss(n: i8) -> f32 {
	let n = n as f32;
	(1.0 / (std::f32::consts::TAU * VARIANCE).sqrt()) * (-(n * n) / (2.0 * VARIANCE)).exp()
}
