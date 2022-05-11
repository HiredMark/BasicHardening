#again no recursion for this unfortunetely that I have yet to find. 
#Commented out sections are due to account not having access. Idealy this code would have the condtion to ignore requests and modules that it doesn't havae permissions for.
module "DestroyNVirginia" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.us-east-1
  }
}
module "DestroyOhio" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.us-east-2
  }
}
module "Destroy2" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.us-west-1
  }
}
module "DestroyNCalifornia" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.us-west-2
  }
}
# module "DestroyOregon" {
#   source = "../vpcdestroyerbase"
#   providers = {
#     aws = aws.af-south-1
#   }
# }
# module "DestroyHongKong" {
#   source = "../vpcdestroyerbase"
#   providers = {
#     aws = aws.ap-east-1
#   }
# }
module "DestroyMumbai" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.ap-south-1
  }
}
# module "DestroyJakarta" {
#   source = "../vpcdestroyerbase"
#   providers = {
#     aws = aws.ap-southeast-3
#   }
# }
module "DestroySeoul" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.ap-northeast-2
  }
}
module "DestroySingapore" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.ap-southeast-1
  }
}
module "DestroySydney" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.ap-southeast-2
  }
}
module "DestroyTokyo" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.ap-northeast-1
  }
}
module "DestroyOsaka" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.ap-northeast-3
  }
}
module "DestroyCanada" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.ca-central-1
  }
}
module "DestroyFrankfurt" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.eu-central-1
  }
}
module "DestroyIreland" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.eu-west-1
  }
}
module "DestroyLondon" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.eu-west-2
  }
}
module "DestroyParis" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.eu-west-3
  }
}
# module "DestroyMilan" {
#   source = "../vpcdestroyerbase"
#   providers = {
#     aws = aws.eu-south-1
#   }
# }
module "DestroyStokholm" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.eu-north-1
  }
}
# module "DestroyBahrain" {
#   source = "../vpcdestroyerbase"
#   providers = {
#     aws = aws.me-south-1
#   }
# }
module "DestroySaoPaolo" {
  source = "../vpcdestroyerbase"
  providers = {
    aws = aws.sa-east-1
  }
}
