Assignment #3: Terraform - Wordpress

What is WordPress? At its core, WordPress is the simplest, most popular way to create your own website or blog. In fact, WordPress powers over 35.2% of all the websites on the Internet. Yes – more than one in four websites that you visit are likely powered by WordPress.

WordPress is an open-source content management system. A content management system is basically a tool that makes it easy to manage important aspects of your website – like content – without needing to know anything about programming.

The end result is that WordPress makes building a website accessible to anyone – even people who aren’t developers. Many years ago, WordPress was primarily a tool to create a blog, rather than more traditional websites. That hasn’t been true for a long time, though. Nowadays, thanks to changes to the core code, as well as WordPress’ massive ecosystem of plugins and themes, you can create any type of website with WordPress.

 

TASK #1:

With Terraform:

Create a VPC named ‘wordpress-vpc’ (add name tag).

Create an Internet Gateway named ‘wordpress_igw’ (add name tag).

Create a route table named ‘wordpess-rt’ and add Internet Gateway route to it (add name tag).

Create 3 public and 3 private subnets in the us-east region (add name tag). Associate them with the ‘wordpess-rt’ route table. What subnets should be associated with the ‘wordpess-rt’ route table? What about other subnets? Use AWS documentation.

Create a security group named ‘wordpress-sg’ and open HTTP, HTTPS, SSH ports to the Internet (add name tag). Define port numbers in a variable named ‘ingress_ports’.

Create a key pair named ‘ssh-key’ (you can use your public key).

Create an EC2 instance named ‘wordpress-ec2’ (add name tag). Use Amazon Linux 2 AMI (can store AMI in a variable), t2.micro, ‘wordpress-sg’ security group, ‘ssh-key’ key pair, public subnet 1.

Create a security group named ‘rds-sg’ and open MySQL port and allow traffic only from ‘wordpress-sg’ security group (add name tag).

Create a MySQL DB instance named ‘mysql’: 20GB, gp2, t2.micro instance class, username=admin, password=adminadmin. Use ‘aws_db_subnet_group’ resource to define private subnets where the DB instance will be created.

 

You have to install wordpress on 'wordpress-ec2'. Desired result: on wordpress-ec2-public-ip/blog address, you have to see wordpress installation page. You can install wordpress manually or through user_data. 

Submit your Terraform code.