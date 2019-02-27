import argparse

APP_CONFIGS = {
    'prometheus_engine': {
        'min_core': 0.5,
        'max_core': 2,
        'min_mem_mb': 2000,
        'max_mem_mb': 6000,
        'min_remote_disk_gb': 50,
        'max_remote_disk_gb': 150,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.005,
        'factor_core_to_mem': 20,
        'factor_core_to_remote_disk': 0.5,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0016,
        'factor_mem_to_mem': 6,
        'factor_mem_to_remote_disk': 0.16,
        'factor_mem_to_local_disk': 0
    },
    'prometheus_push_gateway': {
        'min_core': 0.5,
        'max_core': 2,
        'min_mem_mb': 1000,
        'max_mem_mb': 3000,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.005,
        'factor_core_to_mem': 10,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0016,
        'factor_mem_to_mem': 3,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0
    }
}
ROLES = {
    'monitor-system-alert': {
        'namespace': 'monitor-application',
        'apps': ['prometheus_engine', 'prometheus_push_gateway']
    }
}
NS_RESOURCES = {
    'monitor-application': {
        'cores_req': 35,
        'mem_req_mb': 45000,
        'local_disk_req_gb': 300,
        'remote_disk_req_gb': 200
    }
}

CPU_LIMIT_REQ_RATIO = 1.5
MEM_LIMIT_REQ_RATIO = 1.1

def replace_resourses(role_name, cores, mem_in_gb):
    role = ROLES[role_name]
    apps = role['apps']
    namespace = role['namespace']
    app_replace_vars = {}
    ns_resource_increment = {
        'cores_req': 0,
        'mem_req_mb': 0,
        'local_disk_req_gb': 0,
        'remote_disk_req_gb': 0
    }
    for app in apps:
        result = cal_app_resources(app, cores, mem_in_gb)
        ns_resource_increment['cores_req'] += result['cores_req'] - APP_CONFIGS[app]['min_core']
        ns_resource_increment['mem_req_mb'] += result['mem_req_mb'] - APP_CONFIGS[app]['min_mem_mb']
        ns_resource_increment['local_disk_req_gb'] += result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']
        ns_resource_increment['remote_disk_req_gb'] += result['remote_disk_req_gb'] - APP_CONFIGS[app]['min_remote_disk_gb']

        app_replace_vars['$' + app + '_cpu_req'] = result['cores_req']
        app_replace_vars['$' + app + '_cpu_limit'] = result['cores_limit']
        app_replace_vars['$' + app + '_mem_req'] = str('%dMi' % result['mem_req_mb'])
        app_replace_vars['$' + app + '_mem_limit'] = str('%dMi' % result['mem_limit_mb'])
        app_replace_vars['$' + app + '_local_disk_req'] = str('%dGi' % result['local_disk_req_gb'])
        app_replace_vars['$' + app + '_remote_disk_req'] = str('%dGi' % result['remote_disk_req_gb'])

    replace_vars_in_file('./templates/' + role_name + '-resource.yml', '../' + role_name + '/vars/resource.yml', app_replace_vars)
    return ns_resource_increment

def replace_vars_in_file(template, dest, vars):
    # Safely read the input filename using 'with'
    with open(template) as f:
        s = f.read()

    # Safely write the changed content, if found in the file
    with open(dest, 'w') as f:
        for key in vars:
            value = str(vars[key])
            print ('Changing "{key}" to "{value}"'.format(**locals()))
            s = s.replace(key, value)
        f.write(s)


def cal_app_resources(app_name, cores, mem_in_gb):
    config = APP_CONFIGS[app_name]
    cores_req = config['factor_core_to_core'] * cores + config['factor_mem_to_core'] * mem_in_gb
    mem_req = config['factor_core_to_mem'] * cores + config['factor_mem_to_mem'] * mem_in_gb
    remote_disk_req = config['factor_core_to_remote_disk'] * cores + config['factor_mem_to_remote_disk'] * mem_in_gb
    local_disk_req = config['factor_core_to_local_disk'] * cores + config['factor_mem_to_local_disk'] * mem_in_gb
    if cores_req < config['min_core']:
        cores_req = config['min_core']
    if cores_req > config['max_core']:
        cores_req = config['max_core']
    if mem_req < config['min_mem_mb']:
        mem_req = config['min_mem_mb']
    if mem_req > config['max_mem_mb']:
        mem_req = config['max_mem_mb']
    if remote_disk_req < config['min_remote_disk_gb']:
        remote_disk_req = config['min_remote_disk_gb']
    if remote_disk_req > config['max_remote_disk_gb']:
        remote_disk_req = config['max_remote_disk_gb']
    if local_disk_req < config['min_local_disk_gb']:
        local_disk_req = config['min_local_disk_gb']
    if local_disk_req > config['max_local_disk_gb']:
        local_disk_req = config['max_local_disk_gb']
    cores_limit = cores_req * CPU_LIMIT_REQ_RATIO
    mem_limit = mem_req * MEM_LIMIT_REQ_RATIO

    return {
        'cores_req': float('%.1f' % cores_req),
        'mem_req_mb': int(mem_req),
        'cores_limit': float('%.1f' % cores_limit),
        'mem_limit_mb': int(mem_limit),
        'remote_disk_req_gb': int(remote_disk_req),
        'local_disk_req_gb': int(local_disk_req)
    }

def main():
    parser = argparse.ArgumentParser(description='The args to calculate resource usage.')

    parser.add_argument('--cluster-total-cores', type=int, help='the total cpu cores of the cluster')
    parser.add_argument('--cluster-total-mem', type=int, help='the total mem in GB of the cluster')

    args = parser.parse_args()
    if args.cluster_total_cores is None or args.cluster_total_mem is None:
        parser.print_help()
        exit(1)
    print(args.cluster_total_cores)
    print(args.cluster_total_mem)

    ns_resources = NS_RESOURCES
    for role_name in ROLES:
        role = ROLES[role_name]
        ns_increment = replace_resourses(role_name, args.cluster_total_cores, args.cluster_total_mem)
        namespace = role['namespace']
        for key in ns_increment:
            ns_resources[namespace][key] += ns_increment[key]
    ns_replace_vars = {}
    for namespace in ns_resources:
        ns_resource = ns_resources[namespace]
        ns_resource['cores_req'] = float('%.1f' % ns_resource['cores_req'] )
        ns_resource['cores_limit'] = ns_resource['cores_req'] * CPU_LIMIT_REQ_RATIO
        ns_resource['mem_req_mb'] = int(ns_resource['mem_req_mb'] )
        ns_resource['mem_limit_mb'] = int(ns_resource['mem_req_mb'] * MEM_LIMIT_REQ_RATIO)
        ns_resource['local_disk_req_gb'] = int(ns_resource['local_disk_req_gb'])
        ns_resource['remote_disk_req_gb'] = int(ns_resource['remote_disk_req_gb'])

        ns_replace_vars['$' + namespace + '_cpu_req'] = ns_resource['cores_req']
        ns_replace_vars['$' + namespace + '_cpu_limit'] = ns_resource['cores_limit']
        ns_replace_vars['$' + namespace + '_mem_req'] = str('%dMi' % ns_resource['mem_req_mb'])
        ns_replace_vars['$' + namespace + '_mem_limit'] = str('%dMi' % ns_resource['mem_limit_mb'])
        ns_replace_vars['$' + namespace + '_local_disk_req'] = str('%dGi' % ns_resource['local_disk_req_gb'])
        ns_replace_vars['$' + namespace + '_remote_disk_req'] = str('%dGi' % ns_resource['remote_disk_req_gb'])
        replace_vars_in_file('./templates/ns-' + namespace + '-resource.yml', '../monitor-namespace/vars/ns-' + namespace + '-resource.yml', ns_replace_vars)

if __name__ == '__main__':
  main()
