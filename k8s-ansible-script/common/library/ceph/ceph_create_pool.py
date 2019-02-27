#!/usr/bin/python


def create_pool(module, pool_name, conffile, keyring):
    ok = False
    info = ""
    try:
        with rados.Rados(conffile=conffile, conf=dict(keyring=keyring)) as cluster:
            if cluster.pool_exists(pool_name):
                info = "Pool %s is already existing" % pool_name
                ok = True
            else:
                cluster.create_pool(pool_name)
                if not cluster.pool_exists(pool_name):
                    info = "Create pool %s failed" % pool_name
                else:
                    ok = True
                    info = "Create pool %s success" % pool_name
    except Exception as err:
        info = "Create pool %s failed: %s" % (pool_name, str(err))
    finally:
        return ok, info


def main():
    module = AnsibleModule(
        argument_spec=dict(
            pool_name=dict(required=True),
            conffile=dict(required=True),
            keyring=dict(required=True)
        )
    )
    pool_name = module.params['pool_name']
    conffile = module.params['conffile']
    keyring = module.params['keyring']
    ok, info = create_pool(module, pool_name, conffile, keyring)
    if ok:
        module.exit_json(changed=False, msg=info)
    else:
        module.fail_json(msg=info)


from ansible.module_utils.basic import *
import rados

main()