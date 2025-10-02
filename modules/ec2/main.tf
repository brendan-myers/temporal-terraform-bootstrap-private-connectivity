data "aws_iam_policy" "s3_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ec2-ssm" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action: ["sts:AssumeRole"],
      Principal = { Service = ["ec2.amazonaws.com"]}
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role = aws_iam_role.ec2-ssm.name
  policy_arn = data.aws_iam_policy.s3_read_only.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role = aws_iam_role.ec2-ssm.name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.tag_prefix}-temporal-ec2-ssm"
  role = aws_iam_role.ec2-ssm.name
}

resource "aws_instance" "this" {
  ami = var.ami
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.this.name
  vpc_security_group_ids = [ var.security_group_id ]
  
  user_data = <<-EOF
#!/bin/bash
set -euxo pipefail

# Fetch the Temporal CLI
sudo aws s3 cp s3://${var.s3_temporal_cli}/temporal /usr/local/bin/
sudo chmod 755 /usr/local/bin/temporal

# Create a script for testing the endpoint
echo "temporal env set \\
--env cloud \\
--key address \\
--value ${var.endpoint_address}:7233" >> /home/ec2-user/test.sh

echo "temporal env set \\
--env cloud \\
--key tls-server-name \\
--value ${var.region}.aws.api.temporal.io" >> /home/ec2-user/test.sh

echo "temporal env set \\
--env cloud \\
--key namespace \\
--value ${var.namespace}" >> /home/ec2-user/test.sh

echo "temporal env set --env cloud --key tls --value true" >> /home/ec2-user/test.sh

echo "export TEMPORAL_API_KEY=${var.temporal_api_key}" >> /home/ec2-user/test.sh

echo "temporal workflow start \\
--type TestWorkflow \\
--task-queue no-workers \\
--env cloud" >> /home/ec2-user/test.sh

echo "sleep 5" >> /home/ec2-user/test.sh

echo "temporal workflow list --env cloud" >> /home/ec2-user/test.sh

chmod +x /home/ec2-user/test.sh
  EOF

  tags = {
    Name = "${var.tag_prefix}-test-host"
  }
}