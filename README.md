# AWS_Resources_Utilization
EC2 instances resource utilisation automation and integration with MS-Teams/Slack

# Pre-requisite-
AWSCLI should be installed and credentials should be mentioned in “~/.aws/credentials” file after running "aws configure" command.

MS-Teams and Slack should be installed, and channel should be created to send the notification, so every member can check resource utilization in last 24 hours to take some action or audit purpose.

## Conditions to be modified for under or over utilization like below-
### For over utilization: Current CPU Utilization Percentage > Maximum CPU Threshold
There is a variable called “maxCPUTheshold” ; where maximum threshold value can be defined, as of now this value is set as “70%”.

### For below utilization: Current CPU Utilization Percentage < Maximum CPU Threshold
There is a variable called “minCPUTheshold” ; where minimum threshold value can be defined, as of now this value is set as “2%”.


### To send the Notification-
An incoming webhook needs to be created at MS-Teams or Slack side. WEBHOOK_URL variable needs to be changed based on your Teams/Slack Channel URL.
