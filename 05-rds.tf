resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 1. Le Secret (Nommage dynamique et rétention intelligente)
resource "aws_secretsmanager_secret" "db_secret-v2" {
  # Nommage professionnel standardisé (ex: prod/app/db-credentials)
  name                    = "${var.env}/app/db-credentials-v2"
  description             = "Identifiants de la base de données RDS pour l'application"
  
  # 30 jours de protection en prod, 0 jour en dev pour faciliter le "terraform destroy" en TP
  recovery_window_in_days = var.env == "prod" ? 30 : 0
}

# 2. Le contenu JSON du Secret
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret-v2.id
  
  secret_string = jsonencode({
    user     = var.db_user_name
    password = random_password.db_password.result
    host     = aws_db_instance.app_db.address 
    db       = aws_db_instance.app_db.db_name
  })
}

resource "aws_db_subnet_group" "db_subnet_group_3-tiers" {
  name       = "app-db-subnet-group-${var.env}"
  subnet_ids = [
    aws_subnet.private_db_subnet_a.id,
    aws_subnet.private_db_subnet_b.id
  ]

  tags = {
    Name = "App DB Subnet Group ${var.env}"
  }
}

resource "aws_db_instance" "app_db" {
  identifier             = "app-database-${var.env}"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  
  db_name                = "appdb"
  username               = var.db_user_name
  password               = random_password.db_password.result
  
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group_3-tiers.name
  vpc_security_group_ids = [aws_security_group.db_sg_3-tiers.id]
  
  # Haute disponibilité activée uniquement en prod (économie de coûts pour les TP)
  multi_az               = var.env == "prod" ? true : false
  
  # Snapshot final obligatoire en prod, désactivé en dev
  skip_final_snapshot    = var.env == "prod" ? false : true  
}