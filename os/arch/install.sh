#!/bin/bash

# This script is used to install the necessary dependencies for the project

# check the $YOZORA_PATH environment variable

if [ -z "$YOZORA_PATH" ]; then
	echo "YOZORA_PATH is not set. Please set the environment variable to the root of the project"
	exit 1
fi

# Usage: ./install.sh <package_collection>
# or if the bashrc is sourced then: `update <package_collection>`
#
# -l or --list to list the available package collections
# -h or --help to display the help message
# -a or --all to install all the available package collections

arch_sub_path="os/arch"
pkg_path="$YOZORA_PATH/os/arch/pkg-collections"
install_script="$YOZORA_PATH/$arch_sub_path/tools/package-manager/install-packages.sh"

source "$YOZORA_PATH/$arch_sub_path/tools/package-manager/lib.sh"

is_directory() {
	local path=$1
	local component=$2

	if ! [ -z "$component" ]; then
		path="$HOME/.config/$component/pkgs/$path"
	else
		path="$pkg_path/$path"
	fi

	if [ -d "$path" ]; then
		echo "true"
	else
		echo "false"
	fi
}

list_component_packages() {
	local component=$1
	local component_path=$HOME/.config/$component
	local packages=$(ls $component_path/pkgs | sed 's/\.conf//g')
	package_array=(${package_array[@]/base/})

	for package in $packages; do
		echo -e "\t-> $package ($component)"
	done
}

# TODO: Add support for same named packages in different components
get_component_by_package() {
	local package="$1"

	for component in "${!components_health_status[@]}"; do
		local component_path="$HOME/.config/$component/pkgs"
		if [ -d "$component_path" ]; then
			if [ -f "$component_path/$package.conf" ]; then
				echo "$component"
				return 0
			fi
		fi
	done
	return 1
}

get_multiple_components_by_package() {
	local package="$1"
	local components=()

	for component in "${!components_health_status[@]}"; do
		local component_path="$HOME/.config/$component/pkgs"
		if [ -d "$component_path" ]; then
			if [ -f "$component_path/$package.conf" ]; then
				components+=($component)
			fi
		fi
	done

	echo "${components[@]}"
}

install_package() {
	local package=$1
	local component=$2

	if ! [ -z $component ]; then
		echo "Component found: $component"
		folder="$HOME/.config/$component/pkgs"
	else
		folder=$pkg_path
	fi

	if ! [ -f "$folder/$package.conf" ]; then
		echo "The package: $package does not exist"
		return 1
	fi

	sudo bash "$install_script" --path "$folder" --package "$package.conf"
	bash "$install_script" --path "$folder" --package "$package.conf"
}

remove_package() {
	local package=$1
	local component=$2

	if ! [ -z $component ]; then
		echo "Component found: $component"
		folder="$HOME/.config/$component/pkgs"
	else
		folder="$YOZORA_PATH/pkg-collections"
	fi

	if ! [ -f "$folder/$package.conf" ]; then
		echo "The package: $package does not exist"
		return 1
	fi

	bash "$install_script" --path "$folder" --package "$package.conf" --remove
	sudo bash "$install_script" --path "$folder" --package "$package.conf" --remove
}

list_packages() {
	packages=$(ls $pkg_path | sed 's/\.conf//g')

	echo "Available package collections:"
	for package in $packages; do
		if [ $(is_directory $package) == "true" ]; then
			continue
		fi
		echo -e "\t-> $package"
	done
}

is_unique_named_package() {
	local package=$1

	for a_component in "${!components_health_status[@]}"; do
		for b_component in "${!components_health_status[@]}"; do
			if [[ $a_component == $b_component ]]; then
				continue
			fi
			if [ -f "$HOME/.config/$a_component/pkgs/$package.conf" ] && [ -f "$HOME/.config/$b_component/pkgs/$package.conf" ]; then
				echo "false"
				return 0
			fi
		done
	done

	echo "true"
	return 0
}

help() {
	echo "Usage: ./install.sh <package_collection>"
	echo "or if the bashrc is sourced then: 'update <package_collection>'"
	echo ""
	echo "-l or --list to list the available package collections"
	echo "-h or --help to display the help message"
	echo "-a or --all to install all the available package collections"
	echo "-c or --component to specify the component"
	echo "-p or --package to specify the package collection"
	echo "-r or --remove to remove the package collection (only works with the -p flag)"
}

list() {
	check_component_health

	list_packages

	for component in "${!components_health_status[@]}"; do
		if [ "${components_health_status[$component]}" == "healthy" ]; then
			list_component_packages $component
		fi
	done
}

install_all() {
	packages=$(ls $pkg_path | sed 's/\.conf//g')
	for package in $packages; do
		if [ $(is_directory $package) == "true" ]; then
			continue
		fi
		install_package "$pkg_path/$package.conf"
	done
}

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	"-l" | "--list")
		list
		exit 0
		;;
	"-h" | "--help")
		help
		exit 0
		;;
	"-a" | "--all")
		install_all
		exit 0
		;;
	"-c" | "--component")
		component=$2
		shift
		shift
		;;
	"-p" | "--package")
		package=$2
		shift
		shift
		;;
	"-r" | "--remove")
		remove="--remove"
		shift
		;;
	*)
		package=$1
		shift
		;;
	esac
done
# Process the arguments in switch case

if ! [ -z "$package" ]; then
	if ! [ -z "$component" ]; then
		echo "Component specified: $component and package: $package"
		if [ -z "$remove" ]; then
			install_package $package $component
		else
			remove_package $package $component
		fi
	else
		unique_package=$(is_unique_named_package $package)
		if [[ $unique_package == "true" ]]; then
			component=$(get_component_by_package $package)
			if [ -z "$remove" ]; then
				install_package $package $component
			else
				remove_package $package $component
			fi

			if [ $? -eq 0 ]; then
				echo "The package: $package has been installed successfully"
			else
				echo "The package: $package could not be installed"
			fi
		else
			components=$(get_multiple_components_by_package $package)
			echo "The package: $package is found in multiple components. Please specify the component with the -c flag"
			echo "The package: $package is found in the following components: ${components[@]}"
			echo "Usage: update -c <component> -p $package"
			exit 1
		fi
	fi
fi

if [ -z "$package" ]; then
	install_package "base"
fi
