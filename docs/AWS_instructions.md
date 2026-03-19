# FPGA Developer AMI - 1.19.0 (Ubuntu)

AWS provides this AMI (Amazon Machine Image) as a fully contained development system to develop, simulate and generate an AFI(Amazon FPGA Image).

OS: Ubuntu 24.04
Release Notes: `/home/ubuntu/src/RELEASE_NOTES.md`

## Installed Packages

- Xilinx Tools: 2025.2
- Xilinx XRT
- AWS CLI

## FPGA Developer Kit

- AWS FPGA SDK & HDK are available on github: `https://github.com/aws/aws-fpga`

## Prerequisites

- Go through the [Amazon EC2 Setup process](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html)
- Know [how to launch an EC2 instance from an AMI](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/launching-instance.html)
  - Instance type guidance:
    - Given the large size of the FPGA used for F2, AMD tools work best with at least 8 vCPU's and 32GiB Memory.
    - An instance with less vCPU's and less memory than mentioned above could cause 'Out of memory' failures and much longer build/simulation/flow run times.
    - We reccomend `Compute Optimized` and `Memory Optimized` [instance types](https://aws.amazon.com/ec2/instance-types/) to successfully run the synthesis of acceleration code. Developers may start coding and run simulations on low-cost `General Purpose` [instances types](https://aws.amazon.com/ec2/instance-types/).
- AWS IAM credentials that give permissions to run EC2 instances.
- A Network security group that allows SSH(TCP Port 22)ingress from your host.
  - More information on how to modify/add new security groups [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html#vpc-security-groups)

## Quickstart

1. Launch an Instance using this AMI from the AWS Marketplace using either of the following options:

- 1-Click launch
  - Launches your instance with the default instance, networking, storage and security group settings.
  - Creates a security group that allows ssh ingress from any IP address.
- Manual launch
  - Guides you through the steps to configure the instance, networking, storage and security groups.
  - Lets you increase the project data volume size. You can always expand an EBS volume at a later date if needed.

2. Log into the machine

- ssh as the user `ubuntu` with the key associated with your instance.
- More details on how to connect are provided in the [EC2 documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html)

```bash
ssh -i <Private Key> ubuntu@<Public IP/External DNS Hostname>
```

3. Store your project data

- An EBS volume is mounted at `/home/ubuntu/src/project_data` for storing your project data.
- The EBS volume [size can be increased at any time](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-expand-volume.html)
  - Call 'sudo resize2fs /dev/<volume name>' on the instance after expanding EBS volume to make it usable.

4. Use Xilinx tools

- Test by running simple example:
  `vivado -mode batch -source /home/ubuntu/src/test/counter/gen_bitstream.tcl`

5. Use the AWS FPGA development kit

- Clone it:

```bash
git clone https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR;
```

- Go through the README in the folder within the repository for detailed instructions.

## GUI Desktop Setup

Please refer to our [documentation on github](https://github.com/aws/aws-fpga/blob/master/developer_resources) to setup a GUI Development environment.

## AWS CLI Setup

- AWS CLI is required to register the AFI with AWS and to associate the AFI with an AMI.
- Configure AWS CLI using the IAM credentials from the prerequisite steps.

```bash
aws configure
AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
Default region name [None]: us-east-1 # Substitute the region where you launched your instance.
Default output format [None]: ENTER
```

## AMI Swap Space

The FPGA Developer AMI comes with a built in 20 GiB of swap space.

- Why?
  - Because build jobs will fail if they do not have enough memory to run. Having swap space ensures your job finishes instead of failing with an 'Out of memory' error.
  - If the Instance type you select does not have enough physical memory to run a build job the OS would use the swap space that we provide.
  - Swap space on the root EBS volume will be much slower than the physical memory that you get with the instance.
  - Monitor swap usage on the machine using the `vmstat` command.

## Instance Termination and Resource Cleanup

- When you terminate an instance using this AMI, the project_data EBS volume will not be automatically deleted.
  - This is to protect customers from data loss due to accidental instance termination.
  - The volumes to cleanup can be found in the AWS Console -> EC2 -> Elastic Block Store -> Volumes and can be deleted from the actions button.
- When you launch an instance using a 1-click launch from the marketplace, it will create a new security group for you.
  - On termination, you can locate unused security groups at: AWS Console -> EC2 -> Network and Security -> Security Groups and delete them using the actions button.

## FAQ

- I can not connect to my instance!

  - Please follow the [EC2 troubleshooting guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/TroubleshootingInstancesConnecting.html).

- How do I update to a new AMI with a new Xilinx tool version?

  - Use a separate EBS volume or an EFS Filesystem to work on your project. They can be reattached to a new instance launched with a new FPGA Developer AMI Version.
  - The following steps assume that an EBS volume is mounted at `/home/ubuntu/src/project_data/`
    **WARNING: Your Project Data will be lost when you terminate the instance if the EBS volume property is set to 'Delete on Termination'**

  From the AWS EC2 Console,

  1. Select the instance with the old Xilinx tools that you wish to replace.
  2. Select the Block Device '/dev/sdb' attached to the instance and click on the EBS ID.
  3. Select the EBS Volume, and from Actions choose 'Create Snapshot'. Note down the Snapshot ID: `snap-*`.

     - It might take a while before the snapshot is created. This depends on the amount of data on the Project Data volume.

  4. Launch an instance using the new AMI using manual launch, and when you reach the 'Add Storage' section, use the Snapshot ID for '/dev/sdb'.
  5. The data should be available in `/home/ubuntu/src/project_data/`

- Vivado Issues

  - ERROR: [Coretcl 2-106] Specified part could not be found.
    - The license that we provide is only for the parts that AWS uses on its instances. You get this message if you try to use Xilinx Vivado for other parts.
  - Why is Vivado taking so long to load?
    - This depends on multiple factors like your storage type, storage IO capacity or other processes running on the instance.
    - If you're running Vivado for the first time, it goes through an initial setup phase that takes a bit longer and is fast on subsequent launches.
    - If Vivado is still slow, please try changing the EBS IO type to an optimal level or change to a faster instance type.

- Which Simulators can I use to simulate my design?
  - The FPGA Developer AMI comes with Xilinx Vivado Simulator(xsim) that can be used to simulate your designs.
  - For 3rd party simulators, please refer to the [Xilinx Logic Simulation User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2024_1/ug900-vivado-logic-simulation.pdf)

## References

### Xilinx References

- [Xilinx Website](http://www.xilinx.com/)
- [Xilinx Documentation](http://www.xilinx.com/support.html#documentation)
- [Xilinx Community Forums](https://forums.xilinx.com/)
- [Xilinx Vitis User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2024_1/ug1393-vitis-application-acceleration.pdf)

### AWS EC2 References

- [AWS EC2 Getting Started](https://aws.amazon.com/ec2/getting-started/)
- [AWS EC2 Instance Types](https://aws.amazon.com/ec2/instance-types/)
- [AWS EC2 User Guide](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
- [AWS EC2 Networking and Security](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_Network_and_Security.html)
- [AWS EC2 Key Pairs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
- [AWS EC2 Attach EBS Volume](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html)
- [AWS EC2 Troubleshooting](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-troubleshoot.html)

## Xilinx XRT Sources

- Xilinx hosts XRT source code on the [XRT Github Page](https://github.com/Xilinx/XRT).
- We build XRT RPM's and pre-install them on this AMI for immediate consumption.
- Please check our [documentation for XRT version mappings and instructions on how to install XRT](https://github.com/aws/aws-fpga/blob/master/Vitis/docs/XRT_installation_instructions.md).
