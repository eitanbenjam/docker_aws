# docker_aws
This code will bring up ubuntu instance in aws, install via ansible docker,jenkins and configure job + library

## Installation

in order to run the aws jenkins server you need to perform the following steps:
1. clone repository :
```
git clone https://github.com/eitanbenjam/docker_aws.git
```
2. after repository cloned to your filesystem, we need to build the jenkins instance on aws, this will perform via terraform
```
   cd docker_aws
   terraform init # will init terraform needed modules
   terraform plan # view the resource that are going to be build
   terraform apply -auto-approve # will start creating resources
```
terrafrom will create all needed resource on AWS and in the end of the deployment yout should see the jenkins elastic ip, example:
```
enkins_public_ip = [
  [
    "3.225.168.73",
  ],
]

```
3. check that the instance was created by running the command:
```
    aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0],InstanceId,Platform,State.Name,PrivateIpAddress,PublicIpAddress,InstanceType,PublicDnsName,keypair.Name]' --output table --region us-east-1
```
   output should be a json fora:
```
   -----------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                 DescribeInstances                                                                 |
+-------+----------------------+-------+----------+---------------+---------------+-----------+--------------------------------------------+--------+
|  tikal|  i-0b4232596d4df7aef |  None |  running |  172.31.93.69 |  3.225.168.73 |  t2.micro |  ec2-3-225-168-73.compute-1.amazonaws.com  |  None  |
+-------+----------------------+-------+----------+---------------+---------------+-----------+--------------------------------------------+--------+

```
4. after terraform finished the deployment a could init script will start to work and install/configure jenkins.
   login to machine with the ssh_key that u define in terraform and run the following command to see ansible progress:
tail -f /var/log/cloud-init-output.log
```
    ssh -i tikal_key.pem ubuntu@3.225.168.73
    tail -f /var/log/cloud-init-output.log
```
last line should look like that:
```
PLAY RECAP *********************************************************************
localhost                  : ok=29   changed=24   unreachable=0    failed=0   
```

5. after ansible finish install/configure jenkins open internet browser and browse to http://3.225.168.73:8080/
   u will need to provide the inititial jenkins password that exist in jenkins server under /var/lib/jenkins/secrets/initialAdminPassword

6. after loginto jenkins we need to define admin password:
   enter on the left size of the screen: People -> admin -> Configure  and change admin password then click on Save
7. go to GitHub -> yout repository - > Setting -> webhook , choose your when hook and update jenkins ip address
