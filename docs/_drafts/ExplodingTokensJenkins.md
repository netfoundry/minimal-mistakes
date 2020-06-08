---
title: Exploding Tokens for Jenkins
excerpt: Sometimes temporary trust is enough.
tags:
    - devops
    - jenkins
    - aws-sts
    - aws-secretsmanager
    - security
author: Ken
toc: false
classes: wide
last_updated: June 9, 2019
---

There is a dimensional difference between a security model wherein an authentication token expires and one where it does not. Here is a practical way to achieve temporary trust for privileged Jenkins pipelines using the Security Token Service and Secrets Manager from Amazon Web Services.

## The Gist

1. Put a permanent credential in AWS Secrets Manager.
2. Write an IAM policy that allows you to read that secret.
3. Write a Jenkins Pipeline that prompts for your temporary credential from AWS Security Token Service.

## The Why

### The Line of Sight Analogy

*How does a temporary credential improve security?*

I know I can trust my robots to execute a program, and as long as the robot is in my line-of-sight I have some reason to think it's still running my program. I could make a key for my robot that only opens the doors that robot needs to open, or I could give the robot a copy of my own key. Either way, things get dicey when someone else takes possession of that key, especially if it unlocks the same doors just as well for the thief if it did for my robot. I'll feel a lot better about entrusting the key to a robot if the key only works in my line-of-sight, or only until a particular time.

### Jenkins Credentials Plugin

*What is the motivation for improving the security of secrets stored in Jenkins?*

It is a feature of [the extremely popular Credentials Plugin](https://plugins.jenkins.io/credentials/) to make several types of secrets available in pipelines as environment variables. The confidentiality of these secrets is not modulated by Jenkins's own access controls, and it is not necessary to be a Jenkins administrator nor even a Jenkins user at all to access any secret stored in Jenkins. It is only necessary to push malicious code to any repository that is configured for jobs in Jenkins. Obscuring this is not a viable strategy. Permanent (not automatically "rotated") infrastructure-critical secrets are too frequently stored encrypted-at-rest on the master node which are trivially exfiltrated en masse by any job that is able to run on the master where the plaintext is available, and any one secret may be trivially obtained by any job on any node where the credential ID is known (the ID is not a secret).

It is easy enough to limit the risk of the en masse exfiltration of the entire plaintext of Jenkins secrets. That exploit would require either login access to the host or running a malicious job on the master node. You could configure the master node to have zero workers and carefully control login access via SSH. This does not prevent a malicious job running on any node from obtaining any secret when the ID is known.

## The How

The result of these steps is to entrust a session token to Jenkins which has all of the powers of your own AWS IAM user credential for the next 15 minutes.

### Store a Secret in AWS

You could do this with [AWS Console](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#/listSecrets) or CLI. You could use a `/` separated value for the "name" parameter if you wish to write IAM policies that apply based on a partial match.

```bash
❯ aws secretsmanager create-secret --name /prod/exampleCredential
❯ read -s EXAMPLE_CREDENTIAL
# paste from clipboard and press ENTER
❯ aws secretsmanager put-secret-value --secret-id /prod/exampleCredential --secret-string ${EXAMPLE_CREDENTIAL}
# or
cat > ./exampleCredential.txt
# paste from clipboard and press ENTER
# then press ctrl-d to send EOF
❯ aws secretsmanager put-secret-value --secret-id /prod/exampleCredential --secret-string file://exampleCredential.txt
```

### Write an IAM Policy

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ExamplePolicy",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:/prod/*"
        }
    ]
}
```

### Jenkins Declarative Pipeline

Define a function to prompt the pipeline operator to input a temporary credential.

```groovy
// You could use this as a Jenkins globally shared library (example shown for a file named /vars/getTempCreds.groovy) or at the top of a single pipeline's Jenkinsfile to define the function for use in that particular job (commented def line).
// def getTempCreds() {
def call(params) {
    def command = 'aws sts get-session-token --duration-seconds 900 | jq -r ".Credentials|.SessionToken+\\\":\\\"+.AccessKeyId+\\\":\\\"+.SecretAccessKey"'
    sh(script: "echo '${command}'", label: "Expand to view STS command to retrieve temporary token")
    def message = "Please enter temporary AWS session token.\nTo retrieve this key, issue STS command above from CLI (requires jq command-line JSON processor)\n"
    temp_creds = input   message: "${message}",
            ok: 'Submit',
            parameters: [ password(name: 'tempCred') ]
    return temp_creds
}
```

Assign the output of the function to a variable you can use to get the secret from AWS.

```groovy
def temp_creds = getTempCreds
def aws_session_token = temp_creds['tempCred'].toString().split(':')[0]
def aws_access_key_id = temp_creds['tempCred'].toString().split(':')[1]
def aws_secret_access_key = temp_creds['tempCred'].toString().split(':')[2]

withEnv(["AWS_SESSION_TOKEN=${aws_session_token}",
            "AWS_ACCESS_KEY_ID=${aws_access_key_id}",
            "AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}"]){
    sh (label: "Do something with exampleCredential",
        script: """
            set -e -u -x -o pipefail
            EXAMPLE_CREDENTIAL=$(aws --region us-east-1 secretsmanager get-secret-value --secret-id /prod/exampleCredential | jq -r .SecretString)
            if [[ ! -z ${EXAMPLE_CREDENTIAL:-} ]]; then
                # do something with EXAMPLE_CREDENTIAL
            else
                echo "ERROR: failed to get exampleCredential from Secrets Manager" >&2
                exit 1
            fi
        """,
        returnStdout: false
    )
}

```

### A Least-Privilege Enhancement

You could improve upon this by granting permission to read the secret to an IAM role, and modifying the command to obtain the session token. This would grant only the powers of that role to Jenkins temporarily rather than all the powers of your human credential.

```bash
❯ aws sts assume-role --role-arn arn:aws:iam::{AWS_ACCOUNT_ID}:role/{IAM_ROLE_NAME} --role-session-name {ARBITRARY_UNIQUE_SESSION_NAME}
```
