#!/bin/bash

origin_url_path=$(cat .git/config | grep git@github.com | cut -d ":" -f 2 | cut -d "." -f 1)
repo_data=$(curl -s https://api.github.com/repos/$origin_url_path)

name=$(echo $repo_data | awk -F '"name": "' '{print $2}' | awk -F '"' '{print $1}')
description=$(echo $repo_data | awk -F '"description": "' '{print $2}' | awk -F '"' '{print $1}')

rewrite() {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		# MacOS
		sed -i '' "s/$1/$2/" "$3"
	else
		# Linux
		sed -i "s/$1/$2/" "$3"
	fi
}

rewrite "my-rust-template" "$name" "scripts.sh"

rewrite "name = \"my-rust-template\"" "name = \"$name\"" "Cargo.toml"
rewrite "name = \"my-rust-template\"" "name = \"$name\"" "Cargo.lock"

rewrite "description = \"template for new rust projects\"" "description = \"$description\"" "Cargo.toml"

rewrite "# my-rust-template" "# $name" "README.md"
if [[ "$OSTYPE" == "darwin"* ]]; then
	sed -i '' '3,7d' README.md
else
	sed -i '3,7d' README.md
fi
rewrite "template for new rust projects" "# $description" "README.md"

rm rewrite.sh
