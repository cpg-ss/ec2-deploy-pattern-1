data "aws_ami" "this" {

  for_each = var.instance_object

  executable_users = ["self"]
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = [each.value.ami_name]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = var.instance_object

  name = each.key

  ami                    = data.aws_ami.this[each.key].id
  instance_type          = each.value.instance_type
  key_name               = try(each.value.key_name, null)
  monitoring             = try(each.value.monitoring, false)
  vpc_security_group_ids = try(each.value.vpc_security_group_ids, null)
  subnet_id              = each.value.subnet_id
  iam_instance_profile   = try(each.value.iam_instance_profile, null)

  user_data = try(templatefile("${path.root}/${each.value.user_data.template_path}", each.value.user_data.vars), null)

  tags = try(each.value.tags, {
    Terraform   = "true"
    Environment = "dev"
  })
}
