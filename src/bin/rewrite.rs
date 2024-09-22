use ::std::env;
use ::std::fs::File;
use ::std::io::{BufRead, BufReader};
use ::std::path::Path;
use ::std::process::Command;

fn main() {
	let repository_meta = get_repository_meta();
	println!("repository_meta: {}", repository_meta);
}

fn get_repository_meta() -> String {
	let cwd = env::current_dir().expect("Can't get current directory");
	let git_config_path = Path::new(&cwd).join(".git").join("config");

	let git_config = File::open(git_config_path).expect("Can't open a git config file");

	let reader = BufReader::new(git_config);
	let mut lines = reader.lines();

	let origin_url = lines
		.find(|l| l.is_ok() && l.as_ref().unwrap().contains("git@github.com"))
		.expect("Original URL line not found")
		.unwrap();

	let mut origin_url_path = origin_url.split(":");
	origin_url_path.next();
	let origin_url_path = origin_url_path.next().expect("Original URL parsing error");
	let origin_url_path = origin_url_path
		.split(".")
		.next()
		.expect("Original URL parsing error");

	let meta = Command::new("curl")
		.arg(format!("https://api.github.com/repos/{origin_url_path}"))
		.output()
		.expect("failed to execute curl");

	return String::from_utf8_lossy(&meta.stdout).to_string();
}
