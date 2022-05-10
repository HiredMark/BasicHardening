# BasicHardening

# CloudTrail Requirements
1. Enable CloudTrail
    1. Ensure CloudTrail is enabled in all regions
    2. Ensure CloudTrail log file validation is enabled.
    3. Ensure that both management and global events are captured within CloudTrail.
    4. Ensure CloudTrail logs are encrypted at rest using KMS customer managed CMKs.
2. Ensure CloudTrail logs are stored within an S3 bucket.
    1. Ensure controls are in place to block public access to the bucket.
    2. Ensure S3 bucket access logging is enabled on the CloudTrail S3 bucket.
3. Ensure CloudTrail trails are integrated with CloudWatch Logs.

# CloudWatch Filters and Alarms Requirements
4. Unauthorized API calls
5. Management Console sign-in without MFA
6. Usage of the "root" account

# Remove Default VPC
7. Remove the default VPC within every region of the account

# Design considerations

1. Security hardening propbably needs to be something that repeats over and over. So it will be designed as a module to be implemented over and over again.

2. Don't use credentials so I will be using AWS CLI to store credentials in this case. This is imperfect as the credentials still exist on my computer in a plain text file. Ideally I would be using HashiCorp Vault

3. Logs ideally should be isolated away from the original account. Therefore this should drop logs at an existing bucket. But in this case the bucket will have to be in the original account, simply to control the scope of the project and to allow for it to be interrogated.

4. Ideally a backend should be remote but in this case it would be local. So the tfstate file will be in the git repo

5. I will not use .gitignore so as to allow for full visibility into the project for assessment

# Design Structure

This is the key project structure in a tree diagram

```
TaskforDD
  ├───modules 
  │   └───Sec
  |        └───Sec.tf
  |        └───terraform.tfvars
  |        └───variables.tf
  └───main.tf
  └───providers.tf
```

