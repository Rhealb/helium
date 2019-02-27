import argparse

# cpu and memory are calculated with a largest cluster with 2000 cores and 10000GB memory
# and cpu and memory with the same weight for the factor, for example:
# {{factor_core_to_mem}} * 2000 = {{factor_mem_to_mem}} * 10000 = 0.5 * max_mem_mb

# local disk size are calculated with a smallest cluster with 100 cores and 250GB memory or
# calculated with a largest cluster with 2000 cores and 10000GB memory

APP_CONFIGS = {
    'elasticsearch_master': {
        'instance_count': 2,
        'min_core': 0.5,
        'max_core': 2.0,
        'min_mem_mb': 1100,
        'max_mem_mb': 2200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.55,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.11,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0
    },
    'elasticsearch_data': {
        'instance_count': 3,
        'min_core': 1.0,
        'max_core': 8,
        'min_mem_mb': 4400,
        'max_mem_mb': 16400,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 50,
        'max_local_disk_gb': 500,
        'factor_core_to_core': 0.002,
        'factor_core_to_mem': 4.1,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.25,
        'factor_mem_to_core': 0.0004,
        'factor_mem_to_mem': 0.82,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.1
    },
    'elasticsearch_client': {
        'instance_count': 1,
        'min_core': 0.5,
        'max_core': 4,
        'min_mem_mb': 2200,
        'max_mem_mb': 4400,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.001,
        'factor_core_to_mem': 1.1,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0002,
        'factor_mem_to_mem': 0.22,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0
    },
    'hbase_master': {
        'instance_count': 3,
        'min_core': 0.3,
        'max_core': 2,
        'min_mem_mb': 1000,
        'max_mem_mb': 2000,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.5,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.1,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0
    },
    'hbase_regionserver': {
        'instance_count': 3,
        'min_core': 1,
        'max_core': 8,
        'min_mem_mb': 2000,
        'max_mem_mb': 10000,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.002,
        'factor_core_to_mem': 2.5,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0004,
        'factor_mem_to_mem': 0.5,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0
    },
    'hadoop_hdfs_namenode': {
        'instance_count': 2,
        'min_core': 0.5,
        'max_core': 2,
        'min_mem_mb': 1500,
        'max_mem_mb': 2500,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 5,
        'max_local_disk_gb': 15,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.55,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.025,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.11,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.01
    },
    'hadoop_hdfs_journalnode': {
        'instance_count': 3,
        'min_core': 0.5,
        'max_core': 2,
        'min_mem_mb': 1100,
        'max_mem_mb': 2200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 5,
        'max_local_disk_gb': 15,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.55,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.025,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.11,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.01
    },
    'hadoop_hdfs_datanode': {
        'instance_count': 3,
        'datadir_storage_count': 4,
        'min_core': 0.5,
        'max_core': 2,
        'min_mem_mb': 1100,
        'max_mem_mb': 2200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 30,
        'max_local_disk_gb': 500,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.55,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.15,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.11,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.06
    },
    'kafka': {
        'instance_count': 3,
        'min_core': 0.5,
        'max_core': 2,
        'min_mem_mb': 2200,
        'max_mem_mb': 4400,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 15,
        'max_local_disk_gb': 150,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 1.1,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.075,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.22,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.03
    },
    'opentsdb': {
        'instance_count': 2,
        'min_core': 1,
        'max_core': 4,
        'min_mem_mb': 2200,
        'max_mem_mb': 8200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.001,
        'factor_core_to_mem': 2.05,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0002,
        'factor_mem_to_mem': 0.41,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0
    },
    'spark_master': {
        'instance_count': 3,
        'min_core': 0.2,
        'max_core': 2,
        'min_mem_mb': 1100,
        'max_mem_mb': 2200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 20,
        'max_local_disk_gb': 200,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.55,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.1,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.11,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.04
    },
    'spark_worker': {
        'instance_count': 3,
        'min_core': 2,
        'max_core': 8,
        'min_mem_mb': 6200,
        'max_mem_mb': 12200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 20,
        'max_local_disk_gb': 100,
        'factor_core_to_core': 0.002,
        'factor_core_to_mem': 3.05,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.1,
        'factor_mem_to_core': 0.0004,
        'factor_mem_to_mem': 0.61,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.04
    },
    'spark_historyserver': {
        'instance_count': 1,
        'min_core': 0.2,
        'max_core': 2,
        'min_mem_mb': 1100,
        'max_mem_mb': 2200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 0,
        'max_local_disk_gb': 0,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.55,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.11,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0
    },
    'zookeeper': {
        'instance_count': 3,
        'min_core': 0.2,
        'max_core': 2,
        'min_mem_mb': 1100,
        'max_mem_mb': 2200,
        'min_remote_disk_gb': 0,
        'max_remote_disk_gb': 0,
        'min_local_disk_gb': 2,
        'max_local_disk_gb': 5,
        'factor_core_to_core': 0.0005,
        'factor_core_to_mem': 0.55,
        'factor_core_to_remote_disk': 0,
        'factor_core_to_local_disk': 0.01,
        'factor_mem_to_core': 0.0001,
        'factor_mem_to_mem': 0.11,
        'factor_mem_to_remote_disk': 0,
        'factor_mem_to_local_disk': 0.004
    }
}
ROLES = {
    'monitor-bigdata': {
        'namespace': 'monitor-essential-service',
        'apps': ['elasticsearch_master',
                 'elasticsearch_data',
                 'elasticsearch_client',
                 'hbase_master',
                 'hbase_regionserver',
                 'hadoop_hdfs_namenode',
                 'hadoop_hdfs_journalnode',
                 'hadoop_hdfs_datanode',
                 'kafka',
                 'opentsdb',
                 'spark_master',
                 'spark_worker',
                 'spark_historyserver',
                 'zookeeper'
                 ]
    }
}
NS_RESOURCES = {
    'monitor-essential-service': {
        'cores_req': 35,
        'mem_req_mb': 102800,
        'local_disk_req_gb': 750,
        'remote_disk_req_gb': 200
    }
}

CPU_LIMIT_REQ_RATIO = 1.0
MEM_LIMIT_REQ_RATIO = 1.1

RESERVE_JAVA_MEM_IN_MB = 400

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
        # ns_resource_increment['local_disk_req_gb'] += result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']
        # ns_resource_increment['remote_disk_req_gb'] += result['remote_disk_req_gb'] - APP_CONFIGS[app]['min_remote_disk_gb']

        app_replace_vars['$' + app + '_instancecount'] = APP_CONFIGS[app]['instance_count']
        app_replace_vars['$' + app + '_requestcpu'] = quote_value(str(result['cores_req']))
        app_replace_vars['$' + app + '_limitcpu'] = quote_value(str(result['cores_limit']))
        app_replace_vars['$' + app + '_requestmem'] = quote_value(str('%dMi' % result['mem_req_mb']))
        app_replace_vars['$' + app + '_limitmem'] = quote_value(str('%dMi' % result['mem_limit_mb']))
        # app_replace_vars['$' + app + '_requestlocaldisk'] = str('%dGi' % result['local_disk_req_gb'])
        # app_replace_vars['$' + app + '_requestremotedisk'] = str('%dGi' % result['remote_disk_req_gb'])

        # replace java xmx and xms and calculate storage size for each app
        app_xmx = result['mem_limit_mb'] - RESERVE_JAVA_MEM_IN_MB
        if (app == "elasticsearch_master"):
            app_replace_vars['$elasticsearch_master_javaXmx'] = quote_value(str('%dm' % (app_xmx/2)))
            app_replace_vars['$elasticsearch_master_javaXms'] = quote_value(str('%dm' % (app_xmx/2)))
        if (app == "elasticsearch_data"):
            app_replace_vars['$elasticsearch_data_javaXmx'] = quote_value(str('%dm' % (app_xmx/2)))
            app_replace_vars['$elasticsearch_data_javaXms'] = quote_value(str('%dm' % (app_xmx/2)))
            app_replace_vars['$elasticsearch_esdatastoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']
        if (app == "elasticsearch_client"):
            app_replace_vars['$elasticsearch_client_javaXmx'] = quote_value(str('%dm' % (app_xmx/2)))
            app_replace_vars['$elasticsearch_client_javaXms'] = quote_value(str('%dm' % (app_xmx/2)))
        if (app == "hbase_master"):
            app_replace_vars['$hbase_master_xmx'] = quote_value(str('%dm' % app_xmx))
        if (app == "hbase_regionserver"):
            app_replace_vars['$hbase_regionserver_xmx'] = quote_value(str('%dm' % app_xmx))
        if (app == "hadoop_hdfs_namenode"):
            app_replace_vars['$hadoop_hdfs_specusepvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']
        if (app == "hadoop_hdfs_journalnode"):
            app_replace_vars['$hadoop_hdfs_specusepvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']
        if (app == "hadoop_hdfs_datanode"):
            app_replace_vars['$hadoop_hdfs_datadirstoragecount'] = APP_CONFIGS[app]['datadir_storage_count']
            app_replace_vars['$hadoop_hdfs_datadirpvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count'] * APP_CONFIGS[app]['datadir_storage_count']
        if (app == "kafka"):
            app_replace_vars['$kafka_logpvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']
        if (app == "opentsdb"):
            app_replace_vars['$opentsdb_javaxmx'] = quote_value(str('%dm' % app_xmx))
            app_replace_vars['$opentsdb_javaxms'] = quote_value(str('%dm' % app_xmx))
        if (app == "spark_master"):
            # TODO this is not correct for {{spark_localdirpvcstoragesize}}, we just use master app for calculating local dir size whcih is used for worker
            app_replace_vars['$spark_localdirpvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']
        if (app == "spark_worker"):
            app_replace_vars['$spark_workerworkdirpvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']
        if (app == "zookeeper"):
            app_replace_vars['$zookeeper_datapvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']
            app_replace_vars['$zookeeper_datalogpvcstoragesize'] = quote_value(str('%dGi' % result['local_disk_req_gb']))
            ns_resource_increment['local_disk_req_gb'] += (result['local_disk_req_gb'] - APP_CONFIGS[app]['min_local_disk_gb']) * APP_CONFIGS[app]['instance_count']

    replace_vars_in_file('./templates/' + role_name + '-resource.yml', '../' + role_name + '/defaults/main.yml', app_replace_vars)
    return ns_resource_increment

def replace_vars_in_file(template, dest, vars):
    # Safely read the input filename using 'with'
    with open(template) as f:
        s = f.read()

    # Safely write the changed content, if found in the file
    with open(dest, 'w') as f:
        for key in vars:
            value = str(vars[key])
            print ('In file {dest} Changing "{key}" to "{value}"'.format(**locals()))
            s = s.replace(key, value)
        f.write(s)

def quote_value(value):
    return "\"" + value + "\""


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
    mem_limit = mem_req

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
        ns_resource['cores_limit'] = ns_resource['cores_req'] * CPU_LIMIT_REQ_RATIO + 15
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
