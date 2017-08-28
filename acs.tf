provider "aws" {
  region = "${var.AWS_REGION}"
  profile = "${var.AWS_PROFILE_NAME}"
}

resource "aws_instance" "web-server" {
    count = "${var.AWS_COUNT_ACS}"
    availability_zone = "${element(var.AVZ[var.AWS_REGION], count.index)}"
    ami = "${lookup(var.AWS_AMI,var.AWS_REGION)}"
    key_name = "${var.AWS_KEY_NAME}"
    instance_type = "${var.AWS_INSTANCE_TYPE}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = [
      "${aws_security_group.allow_ssh.id}"
       ]
  tags {
    Name = "acs-server${count.index}"
    Tier = "admin"
    Role = "Ansible_Control_Server"
       }
  provisioner "remote-exec" {
    inline = [
      "sudo rpm -Uhv https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
      "sudo yum clean all",
      "sudo yum install ansible vim mc -y",
      "sudo yum update -y",
      "sudo useradd -d /home/ansible-user -m -p $(echo '${var.ANSIBLE_PASSWORD_PLAIN}' | openssl passwd -1 -stdin) ansible-user",
      "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
      "sudo sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config",
      "sudo systemctl reload sshd",
      "sudo cp /tmp/ansible-user-sudoers /etc/sudoers.d",
      "sudo chown root:root /etc/sudoers.d/ansible-user-sudoers",
      "sudo chmod 440 /etc/sudoers.d/ansible-user-sudoers",
      "sudo rm -rf /tmp/ansible-user-sudoers",
      "sudo -u ansible-user mkdir /home/ansible-user/.ssh",
      "sudo -u ansible-user chmod 700 /home/ansible-user/.ssh",
      "sudo -u ansible-user ssh-keygen -t rsa -b 4096 -N '' -f /home/ansible-user/.ssh/ansible-key",
      "sudo -u ansible-user chmod 644 /home/ansible-user/.ssh/ansible-key.pub",
      "sudo -u ansible-user chmod 600 /home/ansible-user/.ssh/ansible-key"
             ]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${file(".ssh/aws_ec2_Alex")}"
    }
  }
}
