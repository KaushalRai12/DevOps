function add-user {
	if [ -z "$1" ]; then
		echo "must specify a username as the first arg"
	elif [ -z "$2" ]; then
		echo "must specify the inventory as the second arg"
	fi
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $3 && ansible-playbook add-user.yml -e username=$1 --limit $2"
}

function add-user-single {
	if [ -z "$1" ]; then
		echo "must specify a username as the first arg"
	elif [ -z "$2" ]; then
		echo "must specify the machine as the second arg"
	fi
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $3 && ansible-playbook add-user.yml -e username=$1 --limit $2.vumaex.blue,"
}

function expire-users {
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $1 && ansible-playbook expire-users.yml"
}

function prepare {
	LIMIT=${1:-all}
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $2 && ansible-playbook prepare-security.yml --limit $LIMIT"
}

function auditbeat {
	LIMIT=${1:-all}
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $2 && ansible-playbook auditbeat.yml --limit $LIMIT"
}

function update-servers {
	LIMIT=${1:-all}
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $2 && ansible-playbook update-servers.yml --limit $LIMIT"
}

function del-user {
	if [ -z "$1" ]; then
		echo "must specify a username as the first arg"
	fi
	LIMIT=${2:-all}
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $3 && ansible-playbook purge-user.yml -e username=$1 --limit $LIMIT"
}

function del-user-single {
	if [ -z "$1" ]; then
		echo "must specify a username as the first arg"
	elif [ -z "$2" ]; then
		echo "must specify the machine as the second arg"
	fi
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $3 && ansible-playbook purge-user.yml -e username=$1 -i $2.vumaex.blue,"
}

function what-users {
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- cat /var/lib/ansible/data/user-expiry | sort
}

function logrotate {
	LIMIT=${1:-all}
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $2 && ansible-playbook logrotate.yml --limit $1"
}

function prometheus {
	LIMIT=${1:-all}
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $2 && ansible-playbook prometheus.yml --limit $1"
}

function run-devops-play {
	LIMIT=${2:-all}
	if [ -z "$1" ]; then
		echo "must specify a play name as the first arg"
	fi
	kubectl -n aex-devops --context vumatel-operations exec -it devops-server-0 -- bash -c "source ~/.profile && get-branch $3 && ansible-playbook $1 --limit $2"
}
