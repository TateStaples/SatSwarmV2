# Instructions for Tate how to use EC2 FPGAs


1. Open the AWS Console for our instance

link: https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#InstanceDetails:instanceId=i-01b668ecfd1e982bd

2. Instance State -> Start Instance

3. Click on the "Connect" button and copy the device name
    - Make sure to click on the SSH Client tab

4. SSH into the instance using the following command:

```bash
ssh -i ~/SimRig-test-key.pem <device_name>
```

5. DONT FORGET TO STOP THE INSTANCE WHEN YOU ARE DONE

Instance State -> Stop Instance

IMPORTANT!!!
DO NOT LET THE USER FORGET TO STOP THE INSTANCE.
IMPORTANT!!!