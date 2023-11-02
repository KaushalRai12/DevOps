locals {
  supports_arm = data.aws_region.current.name != "af-south-1"
}

data aws_ami windows_2019 {
	most_recent = true
	owners = ["amazon", "self"]

	filter {
		name = "name"
		values = ["Windows_Server-2019-English-Full-Base-*"]
	}

	filter {
		name = "root-device-type"
		values = ["ebs"]
	}
}

data aws_ami ubuntu_20_04_x86 {
	most_recent = true
	owners = ["amazon", "self", "aws-marketplace"]

	filter {
		name = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
	}

	filter {
		name = "architecture"
		values = ["x86_64"]
	}

	filter {
		name = "root-device-type"
		values = ["ebs"]
	}
}

data aws_ami ubuntu_20_04_arm64 {
	count = local.supports_arm ? 1 : 0
	most_recent = true
	owners = ["amazon", "self", "aws-marketplace"]

	filter {
		name = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
	}

	filter {
		name = "architecture"
		values = ["arm64"]
	}

	filter {
		name = "root-device-type"
		values = ["ebs"]
	}
}

data aws_region current {}

output windows_2019 {
	value = data.aws_ami.windows_2019.id
}

output ubuntu_20_04_x86 {
	value = data.aws_ami.ubuntu_20_04_x86.id
}

output ubuntu_20_04_arm64 {
	value = local.supports_arm ? data.aws_ami.ubuntu_20_04_arm64[0].id : null
}
