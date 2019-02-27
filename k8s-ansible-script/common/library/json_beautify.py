#!/usr/bin/python

def json_beautify(module, path):
    ok = False
    info = ""
    try:
        with open(path, 'r+') as f:
            parsed = json.load(f)
            f.seek(0)
            f.truncate()
            json.dump(parsed, f, indent=4, sort_keys=True)
        ok = True
        info = "Beautify %s success" % path
    except Exception as err:
        info = "Beautify %s failed: %s" % (path, str(err))
    finally:
        return ok, info


def main():
    module = AnsibleModule(
        argument_spec=dict(
            path=dict(required=True)
        )
    )
    path = module.params['path']
    ok, info = json_beautify(module, path)
    if ok:
        module.exit_json(changed=False, msg=info)
    else:
        module.fail_json(msg=info)


from ansible.module_utils.basic import *
import json

main()
