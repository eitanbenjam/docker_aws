# docker_aws

# repository goal
perform CI (compile,build test and deploy) on https://github.com/eitanbenjam/tikal_eitan_exam.git repository.

This code will bring up Ubuntu instance in AWS responsible of bring Ubuntu 18.04 instance in AWS via terraform, run cloud-init script that install ansible, and then run a playbook that install ansible docker,jenkins and configure job + library.

* see additional repository




## Installation

in order to run the AWS jenkins server you need to perform the following steps:
1. clone repository :
```
git clone https://github.com/eitanbenjam/docker_aws.git
```
2. after repository cloned to your filesystem, we need to build the jenkins instance on AWS, this will perform via terraform
```
   cd docker_aws
   terraform init # will download terraform needed modules
   terraform plan # view the resource that are going to be build
   terraform apply -auto-approve # will start creating resources
```
terrafrom will create all needed resource on AWS and in the end of the deployment you should see the jenkins elastic ip, example:
```
jenkins_public_ip = [
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
tail -f /var/log/cloud-init-output.log (see ansible tasks)
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
   u will need to provide the initial jenkins password that exist in jenkins server under /var/lib/jenkins/secrets/initialAdminPassword

6. after login into jenkins we need to define admin password:
   enter on the left size of the screen: People -> admin -> Configure  and change admin password then click on Save
7. go to GitHub -> your repository - > Setting -> webhook , choose your when hook and update jenkins ip address
8. 
# ansbile tasks
When instance comes up it automatic run ansible as cloud-init service.
ansible playbook.yaml (a part of that repository) is responsible to install jdk, docker, jenkins.
also a part of ansible playbook its brring up docker-repository, jenkins-libraries and jenkins plugins.


# additional repository
all jenkins shared libraries source files, job configuration are part of https://github.com/eitanbenjam/docker_jenkins repository, ansible clone that repository into the jenkins machine and copy the needed file into the jenkins file system.

# github integration
ansible install generic-webhook-trigger jenkins plugin that enable 3rd party software (github) to trigger jenkins job after commit (need to configure github with the jeknins url). so on every push to repository a new jenkins job is triggered.  
