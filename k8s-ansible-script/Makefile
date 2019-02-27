.PHONY: console
console:
	@ ansible-playbook -i k8s-cluster/clusters/platform-pro/cluster.yml playbook/console.yml

.PHONY: sync
sync:
	@ git submodule update --init --recursive
