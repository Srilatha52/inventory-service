#!/usr/bin/env python3
import subprocess
import sys

def deploy_with_ansible():
    playbook_path = "deploy_inventory.yml"  # Path to your playbook
    ansible_cmd = [
        "ansible-playbook", playbook_path, "-i", "localhost,", "-c", "local"
    ]

    try:
        # Run the Ansible playbook
        result = subprocess.run(ansible_cmd, capture_output=True, text=True)

        if result.returncode == 0:
            print("Deployment successful!")
            print("STDOUT:\n", result.stdout)
        else:
            print("Error occurred during deployment.")
            print("STDOUT:\n", result.stdout)
            print("STDERR:\n", result.stderr)
            sys.exit(1)

    except FileNotFoundError:
        print("Ansible not found. Please ensure Ansible is installed.")
        sys.exit(1)

if __name__ == "__main__":
    deploy_with_ansible()
