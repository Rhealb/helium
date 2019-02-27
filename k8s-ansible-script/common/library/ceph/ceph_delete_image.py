#!/usr/bin/python


def delete_image(module, pool_name, image_name, conffile, keyring):
    ok = False
    info = ""
    try:
        with rados.Rados(conffile=conffile, conf=dict(keyring=keyring)) as cluster:
            if not cluster.pool_exists(pool_name):
                info = "Pool %s is not existed" % pool_name
                ok = True
            else:
                with cluster.open_ioctx(pool_name) as ioctx:
                    rbd_inst = rbd.RBD()
                    image_list = rbd_inst.list(ioctx)
                    if image_name not in image_list:
                        info = "Image %s is not existed in pool %s" % (image_name, pool_name)
                        ok = True
                    else:
                        with rbd.Image(ioctx, image_name) as rbd_image:
                            if len(rbd_image.list_lockers()) > 0:
                                locker_list = rbd_image.list_lockers()['lockers']
                                for locker in locker_list:
                                    rbd_image.break_lock(locker[0], locker[1])
                            for snap in rbd_image.list_snaps():
                                if rbd_image.is_protected_snap(snap["name"]):
                                    rbd_image.unprotect_snap(snap["name"])
                                rbd_image.remove_snap(snap["name"])
                        rbd_inst.remove(ioctx, image_name)
                        if image_name in rbd_inst.list(ioctx):
                            info = "Delete image %s failed" % image_name
                        else:
                            ok = True
                            info = "Delete image %s success" % image_name
    except Exception as err:
        info = "Delete image %s failed: %s" % (image_name, str(err))
    finally:
        return ok, info


def main():
    module = AnsibleModule(
        argument_spec=dict(
            pool_name=dict(required=True),
            image_name=dict(required=True),
            conffile=dict(required=True),
            keyring=dict(required=True)
        )
    )
    pool_name = module.params['pool_name']
    image_name = module.params['image_name']
    conffile = module.params['conffile']
    keyring = module.params['keyring']
    ok, info = delete_image(module, pool_name, image_name, conffile, keyring)
    if ok:
        module.exit_json(changed=False, msg=info)
    else:
        module.fail_json(msg=info)


from ansible.module_utils.basic import *
import rados
import rbd

main()