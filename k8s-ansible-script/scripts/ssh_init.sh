for i in 6 10 14
do
	ip="10.19.140.$i"
	ssh-keygen -f "/root/.ssh/known_hosts" -R $ip
	sshpass -p enncloud  ssh-copy-id -i /root/.ssh/id_rsa.pub  -o StrictHostKeyChecking=no root@$ip
done 
