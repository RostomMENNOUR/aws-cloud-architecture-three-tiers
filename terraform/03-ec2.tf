data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Amazon's official AMI owner ID

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix = "app-lt-"
  image_id = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type

  vpc_security_group_ids = [aws_security_group.app_sg_3-tiers.id]

  iam_instance_profile {
    name = local.instance_profile_name
  }

# Injection dynamique des variables dans le script bash
user_data = base64encode(templatefile("${path.module}/user_data.tftpl", {
    bucket_name = data.aws_s3_bucket.app_artifacts.bucket
    app_version    = var.app_version
    secret_name    = aws_secretsmanager_secret.db_secret-v2.name
    region         = var.aws_region
    
    # Nouvelles variables pour l'initialisation SQL
    rds_endpoint   = aws_db_instance.app_db.address
    db_user        = var.db_user_name
    db_password    = random_password.db_password.result
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "AppServer-ASG"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name = "app-asg"
  
  vpc_zone_identifier = [
    aws_subnet.private_app_subnet_a.id,
    aws_subnet.private_app_subnet_b.id
  ]
  
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  # Configuration Self-Healing (Statique)
  min_size         = 2
  max_size         = 6
  desired_capacity = 2

  health_check_type = "ELB"
  health_check_grace_period = 60 #300

  launch_template {
    id = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50 # Garde au moins la moitié des serveurs en ligne pendant la mise à jour
    }
  }
}