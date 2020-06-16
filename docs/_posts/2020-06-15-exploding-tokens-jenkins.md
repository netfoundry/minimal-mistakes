---
title: Exploding Tokens for Jenkins
excerpt: Sometimes temporary trust is enough.
tags:
    - devops
    - jenkins
    - security
    - aws-sts
    - aws-secretsmanager
author: Ken
toc: false
classes: wide
last_updated: June 9, 2019
header:
    image: /assets/images/hourglass-header.jpg
---

## Steal my AWS credentials!

```json
{
  "Credentials": {
    "AccessKeyId": "ASIA6KNZ4A2TGDT5I75G",
    "SecretAccessKey": "D+MtTRHTuC/eOwkr1naWtFe05EbWAzjbK4O1DOCK",
    "SessionToken": "IQoJb3JpZ2luX2VjEI3//////////wEaCXVzLWVhc3QtMSJHMEUCIQCkQv+wVdob1OW4fT7HQJFQsraUwE96dJA1X/KV2Bz38gIgOeoUdqtJ6eWonoB63778bW1S1heqDevSAooRgw9WDe8qrQEI9f//////////ARABGgw5ODQ0NzQxOTE1MjYiDMXBhLjvwVG4a3Y11iqBAZQrlxW5bgFRxWZeop6m5GagnQS7IOoAVRpH4PKGwX3myXutcrrYABGP3wGlf7ckDfO9yRX4IwLmvC+IoeoUjboin3jzvgBZqn8MG5PLUWoxsL+pSlV9jmnIi+HDFFvPW1EDEyBs0CuoRxeww22k2/iAo42xCdyC/ObEdo5H68anWzCtu/r2BTreAQZDnR3xJjuaf2EuRDjUg9jOI2LTV2ZjIyP5T9XxMx4yrSWpLRxhuy+dF+ZoIOtaU3ZJfwhQGPK6ycikLeRYPAK6j5RYss3OrdtuTYicbQ1U92AqlR29MWtRX0Ln74rj79W36e2E9ACmkrTFnZnrrMs//eweib53W1iraFaQ9l2snEfRusaXtvniKrtdWp3hYD5HNNP4xVOUM+bNzlpyKkUlVQSwA+pM7gBdk0YE7/ES3BxJaKe4ZVeG6G9E0qV59lq9xyTpm/LjmnVWZA+l+pCfncnez9kHPZMmUZFDUw==",
    "Expiration": "2020-06-08T20:36:01Z"
  }
}
```

<i class="fas fa-hand-point-up"></i> &nbsp; These really are my AWS credentials with administrator privileges. Only, the session for which they are valid expired 15 minutes after I obtained them from Amazon's Security Token Service (STS).

![canonball time bomb](/assets/images/canonball-timer.png){: .align-center}

What follows is a reflection on why you too might decide to only entrust expiring credentials like these to Jenkins instead of storing powerful, long-lived credentials.

## The Why

There's obvious value in automation, and Jenkins is an extremely capable general-purpose automation tool. That competence can lead to it becoming empowered to perform a wide range of very important tasks with credentials that could be quite destructive if misused. The problem with storing a powerful credential in Jenkins is that it's available to **all** of the codebases that Jenkins works with, not just the intended codebase.

### The Line of Sight Analogy

*How does a temporary credential improve security?*

I know I can trust my robots to execute a program, and as long as the robot is in my line-of-sight I have some reason to think it's still running my program. I could make a key for my robot that only opens the doors that robot needs to open, or I could give the robot a copy of my own key. Either way, things get dicey when someone else takes possession of that key, especially if it unlocks the same doors just as well for the thief if it did for my robot. I'll feel a lot better about entrusting the key to a robot if the key only works in my line-of-sight, or only until a particular time.

### Jenkins Credentials Plugin

*What is the motivation for improving the security of secrets stored in Jenkins?*

It is a feature of [the widely-used Credentials Plugin](https://plugins.jenkins.io/credentials/) to make several types of secrets available in pipelines as environment variables. The confidentiality of these secrets is not modulated by Jenkins's own access controls, and it is not necessary to be a Jenkins administrator nor even a Jenkins user at all to access any secret stored in Jenkins. It is only necessary to push malicious code to any repository that is configured for jobs in Jenkins.

Obscuring this is not a viable strategy. Permanent (not automatically and routinely "rotated") infrastructure-critical secrets are too frequently stored encrypted-at-rest on the master node. This entire repository of secrets are trivially lifted by any job that is able to run on the master because the plaintext is available there. Additionally, any one secret may be trivially obtained by any job on any node where the credential ID is known.

It is easy enough to limit the risk of theft of the entire plaintext of Jenkins secrets. That exploit would require either login access to the host or running a malicious job on the master node. You could configure the master node to have zero workers and carefully control login access via SSH. This does not prevent a malicious job running on any node from obtaining any secret when the ID is known. The ID is not a secret.

The Jenkins project publishes best practices in [their wiki](https://wiki.jenkins.io/display/JENKINS/Jenkins+Best+Practices) which bring direct attention to these problems.

Here's [a post from the TrendMicro blog](https://blog.trendmicro.com/trendlabs-security-intelligence/hiding-in-plain-text-jenkins-plugin-vulnerabilities/) about the vulnerability of credentials stored in Jenkins.

## The Gist

1. Put a permanent credential in AWS Secrets Manager.
2. Write an IAM policy that allows you to read that secret.
3. Write a Jenkins Pipeline that prompts for your temporary credential from AWS Security Token Service.

## The How

The result of these steps is to entrust a session token to Jenkins which has all of the powers of your own AWS IAM user credential for the next 15 minutes.

### Store a Secret in AWS

You could do this with [AWS Console](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#/listSecrets) or CLI. You could use a `/` separated value for the "name" parameter if you wish to write IAM policies that apply based on a partial match.

```bash
❯ aws secretsmanager create-secret --name /prod/exampleCredential
```

Then put the secret value with a method that avoids exposing in shell history.

```bash
❯ read -s EXAMPLE_CREDENTIAL
# paste from clipboard and press ENTER
❯ aws secretsmanager put-secret-value --secret-id /prod/exampleCredential --secret-string ${EXAMPLE_CREDENTIAL}

# or with a temporary file

cat > ./exampleCredential.txt
# paste from clipboard and press ENTER
# then press ctrl-d to send EOF
❯ aws secretsmanager put-secret-value --secret-id /prod/exampleCredential --secret-string file://exampleCredential.txt

# or with a named pipe

❯ mkfifo -m0600 /tmp/myfifo
❯ aws secretsmanager put-secret-value --secret-id /prod/exampleCredential --secret-string file:///tmp/myfifo &
❯ cat > /tmp/myfifo
# paste from clipboard and press ENTER
# then press ctrl-d to send EOF
```

### Write an IAM Policy

Attach this policy to your IAM user account or an IAM group of which you are a member. See [a least-privilege enhancement](#a-least-privilege-enhancement) below about an alternative approach to only grant the powers of a role instead of your IAM user.

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
