# 1. Création du bucket S3 privé (Change le nom pour qu'il soit unique au monde)
data "aws_s3_bucket" "app_artifacts" {
  bucket = var.s3_bucket_app
  
  # Permet à "terraform destroy" de vider et supprimer le bucket lors de tes TP
  #force_destroy = true 
}

# 2. Verrouillage total de la sécurité (Le "Block Public Access" vital pour l'examen SAA-C03) blocked on AWS Academy
/*resource "aws_s3_bucket_public_access_block" "app_artifacts_block" {
  bucket                  = aws_s3_bucket.app_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}*/

# 3. Upload automatique de ton code modifié dans le bucket
#github s en charge
/*resource "aws_s3_object" "app_code" {
  bucket = data.aws_s3_bucket.app_artifacts.id
  key    = "code.zip"
  
  # Pointe vers le fichier que tu viens de créer dans ton dossier Terraform
  source = "${path.module}/code.zip" 
  
  # md5 permet à Terraform de détecter si tu modifies le zip plus tard pour le mettre à jour
  etag   = filemd5("${path.module}/code.zip")
}*/