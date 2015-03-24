# Proto
CoreOS cluster configuration generator

## Installation

```bash
$ gem install proto
```

## Usage

### Creating your cluster config templates
In your cluster config you need a hosts key containing an array of all the hosts in your cluster.
You can configure these hosts by using regular YAML inheritance. For a full example take a look at this [cluster-config.yaml](https://github.com/chatspry/proto/tree/master/spec/fixtures/cluster-config.yaml).

```yaml
node: &node
  coreos:
    update:
      reboot-strategy: etcd-lock
      group: beta
hosts:
  - hostname: node.1
    <<: *node
```

### Command line client

#### Plan your cluster and print cloud-config for all host

```bash
$ proto plan
#cloud-config
hostname: node.1
coreos:
  etcd:
...

#cloud-config
hostname: node.2
coreos:
  etcd:
...

#cloud-config
hostname: db.1
coreos:
  etcd:
...
```
