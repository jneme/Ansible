{
  "AWSTemplateFormatVersion" : "2010-09-09",

  "Description" : "AWS CloudFormation Sample Template for WordPress_Chef: WordPress is web software you can use to create a beautiful website or blog. This template installs a highly available, scalable WordPress deployment using a multi-AZ (Availability Zone) Amazon RDS database instance for storage. It demonstrates using the AWS CloudFormation bootstrap scripts to deploy the Chef client and using Chef-client in local mode to deploy WordPress. **WARNING** This template creates an Amazon EC2 instance, an Elastic Load Balancing load balancer, and an Amazon RDS database instance. You will be billed for the AWS resources used if you create a stack from this template.",

  "Parameters" : {

    "KeyName": {
      "Description" : "Name of an existing EC2 key pair to enable SSH access to the instances",
      "Type": "AWS::EC2::KeyPair::KeyName",
      "ConstraintDescription" : "must be the name of an existing EC2 KeyPair."
    },

    "InstanceType" : {
      "Description" : "Web Server EC2 instance type",
      "Type" : "String",
      "Default" : "t2.small",
      "AllowedValues" : [ "t1.micro", "t2.nano", "t2.micro", "t2.small", "t2.medium", "t2.large", "m1.small", "m1.medium", "m1.large", "m1.xlarge", "m2.xlarge", "m2.2xlarge", "m2.4xlarge", "m3.medium", "m3.large", "m3.xlarge", "m3.2xlarge", "m4.large", "m4.xlarge", "m4.2xlarge", "m4.4xlarge", "m4.10xlarge", "c1.medium", "c1.xlarge", "c3.large", "c3.xlarge", "c3.2xlarge", "c3.4xlarge", "c3.8xlarge", "c4.large", "c4.xlarge", "c4.2xlarge", "c4.4xlarge", "c4.8xlarge", "g2.2xlarge", "g2.8xlarge", "r3.large", "r3.xlarge", "r3.2xlarge", "r3.4xlarge", "r3.8xlarge", "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge", "d2.xlarge", "d2.2xlarge", "d2.4xlarge", "d2.8xlarge", "hi1.4xlarge", "hs1.8xlarge", "cr1.8xlarge", "cc2.8xlarge", "cg1.4xlarge"]
,
      "ConstraintDescription" : "must be a valid EC2 instance type."
    },

    "SSHLocation": {
      "Description": "The IP address range that can be used to SSH to the EC2 instances",
      "Type": "String",
      "MinLength": "9",
      "MaxLength": "18",
      "Default": "0.0.0.0/0",
      "AllowedPattern": "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})",
      "ConstraintDescription": "must be a valid IP CIDR range of the for x.x.x.x/x."
    },

    "DBClass" : {
      "Description" : "Database instance class",
      "Type" : "String",
      "Default" : "db.t2.small",
      "AllowedValues" : [ "db.t1.micro", "db.m1.small", "db.m1.medium", "db.m1.large", "db.m1.xlarge", "db.m2.xlarge", "db.m2.2xlarge", "db.m2.4xlarge", "db.m3.medium", "db.m3.large", "db.m3.xlarge", "db.m3.2xlarge", "db.m4.large", "db.m4.xlarge", "db.m4.2xlarge", "db.m4.4xlarge", "db.m4.10xlarge", "db.r3.large", "db.r3.xlarge", "db.r3.2xlarge", "db.r3.4xlarge", "db.r3.8xlarge", "db.m2.xlarge", "db.m2.2xlarge", "db.m2.4xlarge", "db.cr1.8xlarge", "db.t2.micro", "db.t2.small", "db.t2.medium", "db.t2.large"]
,
      "ConstraintDescription" : "must select a valid database instance type."
    },

    "DBName" : {
      "Default": "wordpressdb",
      "Description" : "The WordPress database nae",
      "Type": "String",
      "MinLength": "1",
      "MaxLength": "64",
      "AllowedPattern" : "[a-zA-Z][a-zA-Z0-9]*",
      "ConstraintDescription" : "must begin with a letter and contain only alphanumeric characters."
    },

    "DBUser" : {
      "NoEcho": "true",
      "Description" : "The WordPress database admin account user name",
      "Type": "String",
      "MinLength": "1",
      "MaxLength": "16",
      "AllowedPattern" : "[a-zA-Z][a-zA-Z0-9]*",
      "ConstraintDescription" : "must begin with a letter and contain only alphanumeric characters."
    },

    "DBPassword" : {
      "NoEcho": "true",
      "Description" : "The WordPress database admin account password",
      "Type": "String",
      "MinLength": "8",
      "MaxLength": "41",
      "AllowedPattern" : "[a-zA-Z0-9]*",
      "ConstraintDescription" : "must contain only alphanumeric characters."
    },

    "MultiAZDatabase": {
      "Default": "false",
      "Description" : "Create a multi-AZ MySQL Amazon RDS database instance",
      "Type": "String",
      "AllowedValues" : [ "true", "false" ],
      "ConstraintDescription" : "must be either true or false."
    },

    "WebServerCapacity": {
      "Default": "1",
      "Description" : "The initial nuber of web server instances",
      "Type": "Number",
      "MinValue": "1",
      "MaxValue": "5",
      "ConstraintDescription" : "must be between 1 and 5 EC2 instances."
    },

    "DBAllocatedStorage" : {
      "Default": "5",
      "Description" : "The size of the database (GB)",
      "Type": "Number",
      "MinValue": "5",
      "MaxValue": "1024",
      "ConstraintDescription" : "must be between 5 and 1024 GB."
    }
  },

  "Mappings" : {
    "AWSInstanceType2Arch" : {
      "t1.micro"    : { "Arch" : "PV64"   },
      "t2.nano"     : { "Arch" : "HVM64"  },
      "t2.micro"    : { "Arch" : "HVM64"  },
      "t2.small"    : { "Arch" : "HVM64"  },
      "t2.medium"   : { "Arch" : "HVM64"  },
      "t2.large"    : { "Arch" : "HVM64"  },
      "m1.small"    : { "Arch" : "PV64"   },
      "m1.medium"   : { "Arch" : "PV64"   },
      "m1.large"    : { "Arch" : "PV64"   },
      "m1.xlarge"   : { "Arch" : "PV64"   },
      "m2.xlarge"   : { "Arch" : "PV64"   },
      "m2.2xlarge"  : { "Arch" : "PV64"   },
      "m2.4xlarge"  : { "Arch" : "PV64"   },
      "m3.medium"   : { "Arch" : "HVM64"  },
      "m3.large"    : { "Arch" : "HVM64"  },
      "m3.xlarge"   : { "Arch" : "HVM64"  },
      "m3.2xlarge"  : { "Arch" : "HVM64"  },
      "m4.large"    : { "Arch" : "HVM64"  },
      "m4.xlarge"   : { "Arch" : "HVM64"  },
      "m4.2xlarge"  : { "Arch" : "HVM64"  },
      "m4.4xlarge"  : { "Arch" : "HVM64"  },
      "m4.10xlarge" : { "Arch" : "HVM64"  },
      "c1.medium"   : { "Arch" : "PV64"   },
      "c1.xlarge"   : { "Arch" : "PV64"   },
      "c3.large"    : { "Arch" : "HVM64"  },
      "c3.xlarge"   : { "Arch" : "HVM64"  },
      "c3.2xlarge"  : { "Arch" : "HVM64"  },
      "c3.4xlarge"  : { "Arch" : "HVM64"  },
      "c3.8xlarge"  : { "Arch" : "HVM64"  },
      "c4.large"    : { "Arch" : "HVM64"  },
      "c4.xlarge"   : { "Arch" : "HVM64"  },
      "c4.2xlarge"  : { "Arch" : "HVM64"  },
      "c4.4xlarge"  : { "Arch" : "HVM64"  },
      "c4.8xlarge"  : { "Arch" : "HVM64"  },
      "g2.2xlarge"  : { "Arch" : "HVMG2"  },
      "g2.8xlarge"  : { "Arch" : "HVMG2"  },
      "r3.large"    : { "Arch" : "HVM64"  },
      "r3.xlarge"   : { "Arch" : "HVM64"  },
      "r3.2xlarge"  : { "Arch" : "HVM64"  },
      "r3.4xlarge"  : { "Arch" : "HVM64"  },
      "r3.8xlarge"  : { "Arch" : "HVM64"  },
      "i2.xlarge"   : { "Arch" : "HVM64"  },
      "i2.2xlarge"  : { "Arch" : "HVM64"  },
      "i2.4xlarge"  : { "Arch" : "HVM64"  },
      "i2.8xlarge"  : { "Arch" : "HVM64"  },
      "d2.xlarge"   : { "Arch" : "HVM64"  },
      "d2.2xlarge"  : { "Arch" : "HVM64"  },
      "d2.4xlarge"  : { "Arch" : "HVM64"  },
      "d2.8xlarge"  : { "Arch" : "HVM64"  },
      "hi1.4xlarge" : { "Arch" : "HVM64"  },
      "hs1.8xlarge" : { "Arch" : "HVM64"  },
      "cr1.8xlarge" : { "Arch" : "HVM64"  },
      "cc2.8xlarge" : { "Arch" : "HVM64"  }
    },

    "AWSInstanceType2NATArch" : {
      "t1.micro"    : { "Arch" : "NATPV64"   },
      "t2.nano"     : { "Arch" : "NATHVM64"  },
      "t2.micro"    : { "Arch" : "NATHVM64"  },
      "t2.small"    : { "Arch" : "NATHVM64"  },
      "t2.medium"   : { "Arch" : "NATHVM64"  },
      "t2.large"    : { "Arch" : "NATHVM64"  },
      "m1.small"    : { "Arch" : "NATPV64"   },
      "m1.medium"   : { "Arch" : "NATPV64"   },
      "m1.large"    : { "Arch" : "NATPV64"   },
      "m1.xlarge"   : { "Arch" : "NATPV64"   },
      "m2.xlarge"   : { "Arch" : "NATPV64"   },
      "m2.2xlarge"  : { "Arch" : "NATPV64"   },
      "m2.4xlarge"  : { "Arch" : "NATPV64"   },
      "m3.medium"   : { "Arch" : "NATHVM64"  },
      "m3.large"    : { "Arch" : "NATHVM64"  },
      "m3.xlarge"   : { "Arch" : "NATHVM64"  },
      "m3.2xlarge"  : { "Arch" : "NATHVM64"  },
      "m4.large"    : { "Arch" : "NATHVM64"  },
      "m4.xlarge"   : { "Arch" : "NATHVM64"  },
      "m4.2xlarge"  : { "Arch" : "NATHVM64"  },
      "m4.4xlarge"  : { "Arch" : "NATHVM64"  },
      "m4.10xlarge" : { "Arch" : "NATHVM64"  },
      "c1.medium"   : { "Arch" : "NATPV64"   },
      "c1.xlarge"   : { "Arch" : "NATPV64"   },
      "c3.large"    : { "Arch" : "NATHVM64"  },
      "c3.xlarge"   : { "Arch" : "NATHVM64"  },
      "c3.2xlarge"  : { "Arch" : "NATHVM64"  },
      "c3.4xlarge"  : { "Arch" : "NATHVM64"  },
      "c3.8xlarge"  : { "Arch" : "NATHVM64"  },
      "c4.large"    : { "Arch" : "NATHVM64"  },
      "c4.xlarge"   : { "Arch" : "NATHVM64"  },
      "c4.2xlarge"  : { "Arch" : "NATHVM64"  },
      "c4.4xlarge"  : { "Arch" : "NATHVM64"  },
      "c4.8xlarge"  : { "Arch" : "NATHVM64"  },
      "g2.2xlarge"  : { "Arch" : "NATHVMG2"  },
      "g2.8xlarge"  : { "Arch" : "NATHVMG2"  },
      "r3.large"    : { "Arch" : "NATHVM64"  },
      "r3.xlarge"   : { "Arch" : "NATHVM64"  },
      "r3.2xlarge"  : { "Arch" : "NATHVM64"  },
      "r3.4xlarge"  : { "Arch" : "NATHVM64"  },
      "r3.8xlarge"  : { "Arch" : "NATHVM64"  },
      "i2.xlarge"   : { "Arch" : "NATHVM64"  },
      "i2.2xlarge"  : { "Arch" : "NATHVM64"  },
      "i2.4xlarge"  : { "Arch" : "NATHVM64"  },
      "i2.8xlarge"  : { "Arch" : "NATHVM64"  },
      "d2.xlarge"   : { "Arch" : "NATHVM64"  },
      "d2.2xlarge"  : { "Arch" : "NATHVM64"  },
      "d2.4xlarge"  : { "Arch" : "NATHVM64"  },
      "d2.8xlarge"  : { "Arch" : "NATHVM64"  },
      "hi1.4xlarge" : { "Arch" : "NATHVM64"  },
      "hs1.8xlarge" : { "Arch" : "NATHVM64"  },
      "cr1.8xlarge" : { "Arch" : "NATHVM64"  },
      "cc2.8xlarge" : { "Arch" : "NATHVM64"  }
    }
,
    "AWSRegionArch2AMI" : {
      "us-east-1"        : {"PV64" : "ami-2a69aa47", "HVM64" : "ami-6869aa05", "HVMG2" : "ami-1f12e965"},
      "us-west-2"        : {"PV64" : "ami-7f77b31f", "HVM64" : "ami-7172b611", "HVMG2" : "ami-5c9b6124"},
      "us-west-1"        : {"PV64" : "ami-a2490dc2", "HVM64" : "ami-31490d51", "HVMG2" : "ami-7291a112"},
      "eu-west-1"        : {"PV64" : "ami-4cdd453f", "HVM64" : "ami-f9dd458a", "HVMG2" : "ami-b411c5cd"},
      "eu-west-2"        : {"PV64" : "NOT_SUPPORTED", "HVM64" : "ami-886369ec", "HVMG2" : "NOT_SUPPORTED"},
      "eu-central-1"     : {"PV64" : "ami-6527cf0a", "HVM64" : "ami-ea26ce85", "HVMG2" : "ami-be40f2d1"},
      "ap-northeast-1"   : {"PV64" : "ami-3e42b65f", "HVM64" : "ami-374db956", "HVMG2" : "ami-3efd2c58"},
      "ap-northeast-2"   : {"PV64" : "NOT_SUPPORTED", "HVM64" : "ami-2b408b45", "HVMG2" : "NOT_SUPPORTED"},
      "ap-southeast-1"   : {"PV64" : "ami-df9e4cbc", "HVM64" : "ami-a59b49c6", "HVMG2" : "ami-3e91ed5d"},
      "ap-southeast-2"   : {"PV64" : "ami-63351d00", "HVM64" : "ami-dc361ebf", "HVMG2" : "ami-84a142e6"},
      "ap-south-1"       : {"PV64" : "NOT_SUPPORTED", "HVM64" : "ami-ffbdd790", "HVMG2" : "ami-25ffbe4a"},
      "us-east-2"        : {"PV64" : "NOT_SUPPORTED", "HVM64" : "ami-f6035893", "HVMG2" : "NOT_SUPPORTED"},
      "ca-central-1"     : {"PV64" : "NOT_SUPPORTED", "HVM64" : "ami-730ebd17", "HVMG2" : "NOT_SUPPORTED"},
      "sa-east-1"        : {"PV64" : "ami-1ad34676", "HVM64" : "ami-6dd04501", "HVMG2" : "NOT_SUPPORTED"},
      "cn-north-1"       : {"PV64" : "ami-77559f1a", "HVM64" : "ami-8e6aa0e3", "HVMG2" : "NOT_SUPPORTED"},
      "cn-northwest-1"   : {"PV64" : "ami-80707be2", "HVM64" : "ami-cb858fa9", "HVMG2" : "NOT_SUPPORTED"}
    }

  },

  "Conditions" : {
    "Is-EC2-VPC"     : { "Fn::Or" : [ {"Fn::Equals" : [{"Ref" : "AWS::Region"}, "eu-central-1" ]},
                                      {"Fn::Equals" : [{"Ref" : "AWS::Region"}, "cn-north-1" ]}]},
    "Is-EC2-Classic" : { "Fn::Not" : [{ "Condition" : "Is-EC2-VPC"}]}
  },

  "Resources" : {

    "ElasticLoadBalancer" : {
      "Type" : "AWS::ElasticLoadBalancing::LoadBalancer",
      "Metadata" : {
        "Comment1" : "Configure the Load Balancer with a simple health check and cookie-based stickiness",
        "Comment2" : "Use install path for healthcheck to avoid redirects - ELB healthcheck does not handle 302 return codes"
      },
      "Properties" : {
        "AvailabilityZones" : { "Fn::GetAZs" : "" },
        "CrossZone" : "true",
        "LBCookieStickinessPolicy" : [ {
          "PolicyName" : "CookieBasedPolicy",
          "CookieExpirationPeriod" : "30"
        } ],
        "Listeners" : [ {
          "LoadBalancerPort" : "80",
          "InstancePort" : "80",
          "Protocol" : "HTTP",
          "PolicyNames" : [ "CookieBasedPolicy" ]
        } ],
        "HealthCheck" : {
          "Target" : "HTTP:80/wp-admin/install.php",
          "HealthyThreshold" : "2",
          "UnhealthyThreshold" : "5",
          "Interval" : "10",
          "Timeout" : "5"
        }
      }
    },

    "WebServerGroup" : {
      "Type" : "AWS::AutoScaling::AutoScalingGroup",
      "Properties" : {
        "AvailabilityZones" : { "Fn::GetAZs" : "" },
        "LaunchConfigurationName" : { "Ref" : "LaunchConfig" },
        "MinSize" : "1",
        "MaxSize" : "5",
        "DesiredCapacity" : { "Ref" : "WebServerCapacity" },
        "LoadBalancerNames" : [ { "Ref" : "ElasticLoadBalancer" } ]
      },
      "CreationPolicy" : {
        "ResourceSignal" : {
          "Timeout" : "PT15M"
        }
      },
      "UpdatePolicy": {
        "AutoScalingRollingUpdate": {
          "MinInstancesInService": "1",
          "MaxBatchSize": "1",
          "PauseTime" : "PT15M",
          "WaitOnResourceSignals": "true"
        }
      }
    },

    "LaunchConfig": {
      "Type" : "AWS::AutoScaling::LaunchConfiguration",
      "Metadata" : {
        "AWS::CloudFormation::Init" : {
          "configSets" : {
            "wordpress_install" : ["install_cfn", "install_chefdk", "install_chef", "install_wordpress", "run_chef"]
          },
          "install_cfn" : {
            "files": {
              "/etc/cfn/cfn-hup.conf": {
                "content": { "Fn::Join": [ "", [
                  "[main]\n",
                  "stack=", { "Ref": "AWS::StackId" }, "\n",
                  "region=", { "Ref": "AWS::Region" }, "\n"
                ]]},
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              },
              "/etc/cfn/hooks.d/cfn-auto-reloader.conf": {
                "content": { "Fn::Join": [ "", [
                  "[cfn-auto-reloader-hook]\n",
                  "triggers=post.update\n",
                  "path=Resources.LaunchConfig.Metadata.AWS::CloudFormation::Init\n",
                  "action=/opt/aws/bin/cfn-init -v ",
                          "         --stack ", { "Ref" : "AWS::StackName" },
                          "         --resource LaunchConfig ",
                          "         --configsets wordpress_install ",
                          "         --region ", { "Ref" : "AWS::Region" }, "\n"
                ]]},          
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              }
            },
            "services" : {
              "sysvinit" : {
                "cfn-hup" : { "enabled" : "true", "ensureRunning" : "true",
                              "files" : ["/etc/cfn/cfn-hup.conf", "/etc/cfn/hooks.d/cfn-auto-reloader.conf"] }
              }
            }
          },

          "install_chef" : {
            "sources" : {
              "/var/chef/chef-repo" : "http://github.com/opscode/chef-repo/tarball/master"
            },
            "files" : {
              "/tmp/install.sh" : {
                "source" : "https://www.opscode.com/chef/install.sh",
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              },
              "/var/chef/chef-repo/.chef/knife.rb" : {
                "content" : { "Fn::Join": [ "", [
                  "cookbook_path [ '/var/chef/chef-repo/cookbooks' ]\n",
                  "node_path [ '/var/chef/chef-repo/nodes' ]\n"
                ]]},
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              },
              "/var/chef/chef-repo/.chef/client.rb" : {
                "content" : { "Fn::Join": [ "", [
                  "cookbook_path [ '/var/chef/chef-repo/cookbooks' ]\n",
                  "node_path [ '/var/chef/chef-repo/nodes' ]\n"
                ]]},
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              }
            },
            "commands" : {
              "01_make_chef_readable" : {
                "command" : "chmod +rx /var/chef"
              },
              "02_install_chef" : {
                "command" : "bash /tmp/install.sh",
                "cwd"  : "/var/chef"
              },
              "03_create_node_list" : {
                "command" : "chef-client -z -c /var/chef/chef-repo/.chef/client.rb",
                "cwd" : "/var/chef/chef-repo",
                "env" : { "HOME" : "/var/chef" }
              }
            }
          },

          "install_chefdk" : {
            "packages" : {
              "rpm" : {
                "chefdk" : "https://opscode-omnibus-packages.s3.amazonaws.com/el/6/x86_64/chefdk-0.2.0-2.el6.x86_64.rpm"
              }
            }
          },

          "install_wordpress" : {
            "files" : {
              "/var/chef/chef-repo/.chef/knife.rb" : {
                "content" : { "Fn::Join": [ "", [
                  "cookbook_path [ '/var/chef/chef-repo/cookbooks/wordpress/berks-cookbooks' ]\n",
                  "node_path [ '/var/chef/chef-repo/nodes' ]\n"
                ]]},
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              },
              "/var/chef/chef-repo/.chef/client.rb" : {
                "content" : { "Fn::Join": [ "", [
                  "cookbook_path [ '/var/chef/chef-repo/cookbooks/wordpress/berks-cookbooks' ]\n",
                  "node_path [ '/var/chef/chef-repo/nodes' ]\n"
                ]]},
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              },
              "/var/chef/chef-repo/cookbooks/wordpress/attributes/aws_rds_config.rb" : {
                "content": { "Fn::Join": [ "", [
                  "normal['wordpress']['db']['pass'] = '", {"Ref" : "DBPassword"}, "'\n",
                  "normal['wordpress']['db']['user'] = '", {"Ref" : "DBUser"}, "'\n",
                  "normal['wordpress']['db']['host'] = '", {"Fn::GetAtt" : ["DBInstance", "Endpoint.Address"]}, "'\n",
                  "normal['wordpress']['db']['name'] = '", {"Ref" : "DBName"}, "'\n"
                ]]},          
                "mode"  : "000400",
                "owner" : "root",
                "group" : "root"
              }
            },
            "commands" : {
              "01_get_cookbook" : {
                "command" : "knife cookbook site download wordpress",
                "cwd" : "/var/chef/chef-repo",
                "env" : { "HOME" : "/var/chef" }
              },
              "02_unpack_cookbook" : {
                "command" : "tar xvfz /var/chef/chef-repo/wordpress*",
                "cwd" : "/var/chef/chef-repo/cookbooks"
              },
              "03_init_berkshelf": {
                "command" : "berks init /var/chef/chef-repo/cookbooks/wordpress --skip-vagrant --skip-git",
                "cwd" : "/var/chef/chef-repo/cookbooks/wordpress",
                "env" : { "HOME" : "/var/chef" }
              },
              "04_vendorize_berkshelf" : {
                "command" : "berks vendor",
                "cwd" : "/var/chef/chef-repo/cookbooks/wordpress",
                "env" : { "HOME" : "/var/chef" }
              },
              "05_configure_node_run_list" : {
                "command" : "knife node run_list add -z `knife node list -z` recipe[wordpress]",
                "cwd" : "/var/chef/chef-repo",
                "env" : { "HOME" : "/var/chef" }
              }
            }
          },

          "run_chef" : {
            "commands" : {
              "01_run_chef_client" : {
                "command" : "chef-client -z -c /var/chef/chef-repo/.chef/client.rb",
                "cwd" : "/var/chef/chef-repo",
                "env" : { "HOME" : "/var/chef" }
              }
            }
          }
        }
      },
      "Properties": {
        "ImageId" : { "Fn::FindInMap" : [ "AWSRegionArch2AMI", { "Ref" : "AWS::Region" },
                          { "Fn::FindInMap" : [ "AWSInstanceType2Arch", { "Ref" : "InstanceType" }, "Arch" ] } ] },
        "InstanceType"   : { "Ref" : "InstanceType" },
        "SecurityGroups" : [ {"Ref" : "WebServerSecurityGroup"} ],
        "KeyName"        : { "Ref" : "KeyName" },
        "UserData" : { "Fn::Base64" : { "Fn::Join" : ["", [
                       "#!/bin/bash -xe\n",
                       "yum update -y aws-cfn-bootstrap\n",

                       "/opt/aws/bin/cfn-init -v ",
                       "         --stack ", { "Ref" : "AWS::StackName" },
                       "         --resource LaunchConfig ",
                       "         --configsets wordpress_install ",
                       "         --region ", { "Ref" : "AWS::Region" }, "\n",

                       "/opt/aws/bin/cfn-signal -e $? ",
                       "         --stack ", { "Ref" : "AWS::StackName" },
                       "         --resource WebServerGroup ",
                       "         --region ", { "Ref" : "AWS::Region" }, "\n"
        ]]}}
      }
    },

    "DBEC2SecurityGroup": {
      "Type": "AWS::EC2::SecurityGroup",
      "Condition" : "Is-EC2-VPC",
      "Properties" : {
        "GroupDescription": "Open database for access",
        "SecurityGroupIngress" : [{
          "IpProtocol" : "tcp",
          "FromPort" : "3306",
          "ToPort" : "3306",
          "SourceSecurityGroupName" : { "Ref" : "WebServerSecurityGroup" }
        }]
      }
    },

    "DBSecurityGroup": {
      "Type": "AWS::RDS::DBSecurityGroup",
      "Condition" : "Is-EC2-Classic",
      "Properties": {
        "DBSecurityGroupIngress": {
          "EC2SecurityGroupName": { "Ref": "WebServerSecurityGroup" }
        },
        "GroupDescription": "database access"
      }
    },

    "DBInstance" : {
      "Type": "AWS::RDS::DBInstance",
      "Properties": {
        "DBName"            : { "Ref" : "DBName" },
        "Engine"            : "MySQL",
        "MultiAZ"           : { "Ref": "MultiAZDatabase" },
        "MasterUsername"    : { "Ref" : "DBUser" },
        "DBInstanceClass"   : { "Ref" : "DBClass" },
        "AllocatedStorage"  : { "Ref" : "DBAllocatedStorage" },
        "MasterUserPassword": { "Ref" : "DBPassword" },
        "VPCSecurityGroups": { "Fn::If" : [ "Is-EC2-VPC", [ { "Fn::GetAtt": [ "DBEC2SecurityGroup", "GroupId" ] } ], { "Ref" : "AWS::NoValue"}]},
        "DBSecurityGroups": { "Fn::If" : [ "Is-EC2-Classic", [ { "Ref": "DBSecurityGroup" } ], { "Ref" : "AWS::NoValue"}]}
      }
    },

    "WebServerSecurityGroup" : {
      "Type" : "AWS::EC2::SecurityGroup",
      "Properties" : {
        "GroupDescription" : "Enable HTTP access via port 80 locked down to the load balancer + SSH access",
        "SecurityGroupIngress" : [
          {"IpProtocol" : "tcp", "FromPort" : "80", "ToPort" : "80",
"SourceSecurityGroupOwnerId" : {"Fn::GetAtt" : ["ElasticLoadBalancer", "SourceSecurityGroup.OwnerAlias"]},"SourceSecurityGroupName" : {"Fn::GetAtt" : ["ElasticLoadBalancer", "SourceSecurityGroup.GroupName"]}},
          {"IpProtocol" : "tcp", "FromPort" : "22", "ToPort" : "22", "CidrIp" : { "Ref" : "SSHLocation"}}
        ]
      }
    }
  },

  "Outputs" : {
    "WebsiteURL" : {
      "Value" : { "Fn::Join" : ["", ["http://", { "Fn::GetAtt" : [ "ElasticLoadBalancer", "DNSName" ]}]]},
      "Description" : "WordPress website"
    }
  }
}