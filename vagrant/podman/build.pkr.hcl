source "vagrant" "generic-fedora-33" {
  communicator = "ssh"
  source_path = "generic/fedora33"
  add_force = true
}

build {
    name = "podman-fedora-33"

    sources = [ "source.vagrant.generic-fedora-33" ]

    provisioner "shell" {
        scripts = fileset(".", "provision.sh")
    }
}
