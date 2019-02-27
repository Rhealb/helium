#!/usr/bin/python


def create_image(module, pool_name, image_name, image_size, conffile, keyring):
    ok = False
    info = ""
    try:
        with rados.Rados(conffile=conffile, conf=dict(keyring=keyring)) as cluster:
            if not cluster.pool_exists(pool_name):
                info = "Pool %s is not existed" % pool_name
                create_pool(pool_name, conffile, keyring)
            else:
                with cluster.open_ioctx(pool_name) as ioctx:
                    rbd_inst = rbd.RBD()
                    image_list = rbd_inst.list(ioctx)
                    if image_name in image_list:
                        with rbd.Image(ioctx, image_name) as rbd_image:
                            if len(rbd_image.list_lockers()) > 0:
                                locker_list = rbd_image.list_lockers()['lockers']
                                for locker in locker_list:
                                    rbd_image.break_lock(locker[0], locker[1])
                            info = "Image %s is already existing in pool %s, size: %s" % (image_name, pool_name, hurry.filesize.size(rbd_image.size()))
                            ok = True
                    else:
                        size = cal_size(image_size)
                        rbd_inst.create(ioctx, image_name, size, old_format=False, features=1L)
                        if image_name not in rbd_inst.list(ioctx):
                            info = "Create image %s failed" % image_name
                        else:
                            with rbd.Image(ioctx, image_name) as rbd_image:
                                ok = True
                                info = "Create image %s success, size: %s" % (image_name, hurry.filesize.size(rbd_image.size()))
    except Exception as err:
        info = "Create image %s failed: %s" % (image_name, str(err))
    finally:
        return ok, info


def create_pool(pool_name, conffile, keyring):
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
        if not ok:
            raise ValueError(info)


def cal_size(image_size):
    size = 0
    size_num_str = re.search(r'^\d*\.\d+|^\d*', image_size).group(0)
    size_num = float(size_num_str)
    size_unit = image_size[len(size_num_str):]
    if size_unit in ('k', 'K', 'Ki'):
        size = size_num * 1024
    elif size_unit in ('m', 'M', 'Mi'):
        size = size_num * 1024 ** 2
    elif size_unit in ('g', 'G', 'Gi'):
        size = size_num * 1024 ** 3
    elif size_unit in ('t', 'T', 'Ti'):
        size = size_num * 1024 ** 4
    return size


def main():
    module = AnsibleModule(
        argument_spec=dict(
            pool_name=dict(required=True),
            image_name=dict(required=True),
            image_size=dict(required=True),
            conffile=dict(required=True),
            keyring=dict(required=True)
        )
    )
    pool_name = module.params['pool_name']
    image_name = module.params['image_name']
    image_size = module.params['image_size']
    conffile = module.params['conffile']
    keyring = module.params['keyring']
    ok, info = create_image(module, pool_name, image_name, image_size, conffile, keyring)
    if ok:
        module.exit_json(changed=False, msg=info)
    else:
        module.fail_json(msg=info)


from ansible.module_utils.basic import *
import rados
import rbd
import re
import hurry.filesize

main()