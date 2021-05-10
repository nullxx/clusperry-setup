# Cluster info

| host      | IP            |
|-----------|---------------|
| master-01 | 192.168.1.100 |
| node-01   | 192.168.1.101 |
| node-02   | 192.168.1.102 |
| node-03   | 192.168.1.103 |
| node-04   | 192.168.1.104 |
| node-05   | 192.168.1.105 |

#### Ansible `hosts.ini`
```ini
[master]
192.168.1.100

[node]
192.168.1.101
192.168.1.102
192.168.1.103
192.168.1.104
192.168.1.105

[k3s_cluster:children]
master
node
```

# Install glusterfs

### INSTALL IN ALL NODES DEPENDENCIES:
```bash
ansible all -i hosts.ini -a "sudo modprobe fuse" -b
```

```bash
ansible all -i hosts.ini -a "sudo apt-get install -y xfsprogs glusterfs-server" -b
```

```bash
ansible all -i hosts.ini -a "sudo systemctl start glusterd" -b
```

## ONLY ON MASTER NODES:
### Ping all slave nodes
```bash
sudo gluster peer probe 192.168.1.101
```
```bash
sudo gluster peer probe 192.168.1.102
```

```bash
sudo gluster peer probe 192.168.1.103
```

```bash
sudo gluster peer probe 192.168.1.104
```
```bash
sudo gluster peer probe 192.168.1.105
```
### Check the connection status

```bash
sudo gluster peer status
```
### Create folder in all master nodes

```bash
sudo mkdir -p /mnt/glusterfs/myvolume/brick1/
```
### Create the volume
```bash
sudo gluster volume create brick1 192.168.1.100:/mnt/glusterfs/myvolume/brick1/ force
```
### Start the volume

```bash
sudo gluster volume start brick1
```
### Check the volume status
```bash
sudo gluster volume status
```

### Final step: mount them

#### Create the folder in all nodes for mounting (it will create on masters also but wont mount)

```bash
ansible all -i hosts.ini -a "mkdir -p /mnt/general-volume" -b
```

* Mount in all nodes
```
ansible all -i hosts.ini -a "mount -t glusterfs 192.168.1.100:/brick1 /mnt/general-volume" -b
```

# k8s Manifest example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu
  labels:
    app: ubuntu
spec:
  volumes:
    - name: general-volume
      hostPath:
        path: "/mnt/general-volume/test"
  containers:
  - image: ubuntu
    command:
      - "sleep"
      - "604800"
    imagePullPolicy: IfNotPresent
    name: ubuntu
    volumeMounts:
      - mountPath: "/app/data"
        name: general-volume
        readOnly: false
  restartPolicy: Always
```

## Create a file in the container
```bash
kubectl exec -it ubuntu -- mkdir -p /app/data && touch /app/data/hello-world
```

## SSH to any node and check if the new file is there
```bash
ssh ubuntu@192.168.1.102
```
```console
ubuntu@node-02:~$ ls /mnt/general-volume/test
```

You are ready to go!